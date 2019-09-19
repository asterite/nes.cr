require "sdl"
require "./src/nes"

lib LibSDL
  fun SDL_GetTicks : UInt32
end

module SDL
  def self.ticks
    LibSDL.SDL_GetTicks
  end

  class Texture
    def self.new(renderer : Renderer, format : UInt32, access : Int, w : Int, h : Int)
      texture = LibSDL.create_texture(renderer, format, access, w, h)
      raise Error.new("SDL_CreateTextureFromSurface") unless texture
      new(texture)
    end

    def lock(rect, pixels : Void**, pitch : Int32*) : Nil
      value = LibSDL.lock_texture(self, nil, pixels, pitch)
      raise Error.new("SDL_LockTexture") if value != 0
    end

    def unlock
      LibSDL.unlock_texture(self)
    end
  end
end

filename = ARGV.first? || abort("error: missing rom filename")
nes = Nes.new filename

p "PRG banks: #{nes.rom.prg_banks}"
p "CHR banks: #{nes.rom.chr_banks}"
p "MAPPER: #{nes.rom.mapper_number}"
p "Trainer?: #{nes.rom.has_trainer?}"

def color(x)
  x = x.to_u32

  r = (x >> 16) & 0xFF
  g = (x >> 8) & 0xFF
  b = x & 0xFF
  (b << 24) | (g << 16) | (r << 8) | 0xFF
end

PIXELFORMAT_8888 = (1_u32 << 28) |
                   (6_u32 << 24) | # PIXELTYPE_PACKED32
                   (8_u32 << 20) |
                   # (3_u32 << 20) |
                   (6_u32 << 16) | # PACKEDLAYOUT_8888
                   (32_u32 << 8) | # bits
                   (4_u32 << 0)    # bytes

SDL.init(SDL::Init::VIDEO)
window = SDL::Window.new("NES", 256, 240, flags: SDL::Window::Flags.flags(SHOWN, RESIZABLE))
renderer = SDL::Renderer.new(window, SDL::Renderer::Flags::ACCELERATED | SDL::Renderer::Flags::PRESENTVSYNC)
texture = SDL::Texture.new(renderer, PIXELFORMAT_8888, LibSDL::TextureAccess::STREAMING.value, 256, 240)
pixels = Pointer(UInt32).malloc(256 * 240)
pitch = 256 * 4

ticks = SDL.ticks
quit = false

loop do
  while event = SDL::Event.poll
    case event
    when SDL::Event::Quit
      quit = true
      break
    when SDL::Event::Keyboard
      case event
      when .keydown?
        case event.sym
        when .z?
          nes.control_pad.press(ControlPad::Button::A)
        when .x?
          nes.control_pad.press(ControlPad::Button::B)
        when .up?
          nes.control_pad.press(ControlPad::Button::Up)
        when .down?
          nes.control_pad.press(ControlPad::Button::Down)
        when .left?
          nes.control_pad.press(ControlPad::Button::Left)
        when .right?
          nes.control_pad.press(ControlPad::Button::Right)
        when .o?
          nes.control_pad.press(ControlPad::Button::Start)
        when .p?
          nes.control_pad.press(ControlPad::Button::Select)
        end
      when .keyup?
        case event.sym
        when .z?
          nes.control_pad.release(ControlPad::Button::A)
        when .x?
          nes.control_pad.release(ControlPad::Button::B)
        when .up?
          nes.control_pad.release(ControlPad::Button::Up)
        when .down?
          nes.control_pad.release(ControlPad::Button::Down)
        when .left?
          nes.control_pad.release(ControlPad::Button::Left)
        when .right?
          nes.control_pad.release(ControlPad::Button::Right)
        when .o?
          nes.control_pad.release(ControlPad::Button::Start)
        when .p?
          nes.control_pad.release(ControlPad::Button::Select)
        end
      end
    end
  end

  break if quit

  now = SDL.ticks
  nes.step(now - ticks)
  ticks = now

  texture.lock(nil, pointerof(pixels).as(Void**), pointerof(pitch))

  i = 0
  240.times do |y|
    256.times do |x|
      pixels[i] = color(nes.ppu.shown[x][y])
      i += 1
    end
  end

  texture.unlock

  renderer.clear
  renderer.copy(texture)
  renderer.present
end
