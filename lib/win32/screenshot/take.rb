module Win32
  module Screenshot
    # Capture Screenshots on Windows with Ruby
    class Take

      class << self
        # Takes a screenshot of the specified object.
        #
        # @example Take a screenshot of the window with the specified title
        #   Win32::Screenshot::Take.of(:window, :title => "Windows Internet Explorer")
        #
        # @example Take a screenshot of the foreground
        #   Win32::Screenshot::Take.of(:foreground)
        #
        # @example Take a screenshot of the desktop
        #   Win32::Screenshot::Take.of(:desktop)
        #
        # @example Take a screenshot of the window with the specified handle
        #   Win32::Screenshot::Take.of(:window, :hwnd => 123456)
        #
        # @example Take a screenshot of the window's client area (e.g. without title bar) with the specified handle
        #   Win32::Screenshot::Take.of(:window, :hwnd => 123456, :context => :client)
        #
        # @example Take a screenshot of the child window with the specified internal class name
        #   Win32::Screenshot::Take.of(:rautomation, RAutomation::Window.new(:hwnd => 123456).child(:class => "Internet Explorer_Server"))
        #
        # @param [Symbol] what the type of the object to take a screenshot of,
        #   possible values are _:foreground_, _:desktop_ and _:window_.
        # @param [Hash] opts options are optional for specifying _:context_ to take a screenshot.
        #   It is possible to specify as many options as are needed for searching for the unique window.
        #   By default the first window with matching identifiers will be taken screenshot of.
        #   It is possible to use in addition to other options a 0-based _:index_ option to search for other windows if multiple
        #   windows match the specified criteria.
        # @option opts [String, Regexp] :title Title of the window
        # @option opts [String, Regexp] :text Visible text of the window
        # @option opts [String, Fixnum] :hwnd Window handle in decimal format
        # @option opts [String, Fixnum] :pid Window process ID (PID)
        # @option opts [String, Fixnum] :index 0-based index to specify n-th window to take a screenshot of if
        #   all other criteria match
        # @option opts [RAutomation::Window] :rautomation RAutomation::Window object to take a screenshot of. Useful for
        #   taking screenshots of the child windows
        # @return [Image] the {Image} of the specified object
        def of(what, opts = {})
          valid_whats = [:foreground, :desktop, :window]
          raise "It is not possible to take a screenshot of '#{what}', possible values are #{valid_whats.join(", ")}" unless valid_whats.include?(what)

          self.send(what, opts)
        end

        alias_method :new, :of

        private

        def foreground(opts)
          hwnd = BitmapMaker.foreground_window
          take_screenshot(:foreground, hwnd, opts)
        end

        def desktop(opts)
          hwnd = BitmapMaker.desktop_window
          take_screenshot(:desktop, hwnd, opts)
        end

        def window(opts)
          area = {:area => opts.delete(:area)}
          win = opts[:rautomation] || RAutomation::Window.new(opts)
          timeout = Time.now + 10
          until win.active?
            if Time.now >= timeout
              Kernel.warn "[WARN] Failed to set window '#{win.locators.inspect}' into focus for taking the screenshot"
              break
            end
            win.activate
          end
          take_screenshot(:window, win.hwnd, opts.merge(area || {}))
        end

        def take_screenshot(what, hwnd, opts)
          validate_coordinates(hwnd, *opts[:area]) if opts[:area]
          case what
          when :desktop
            BitmapMaker.capture_screen(hwnd, opts)
          else
            BitmapMaker.capture_window(hwnd, opts)
          end
        end

        def validate_coordinates(hwnd, x1, y1, x2, y2)
          specified_coordinates = "x1: #{x1}, y1: #{y1}, x2: #{x2}, y2: #{y2}"
          if [x1, y1, x2, y2].any? {|c| c < 0}
            raise "specified coordinates (#{specified_coordinates}) are invalid - cannot be negative!"
          end

          if x1 >= x2 || y1 >= y2
            raise "specified coordinates (#{specified_coordinates}) are invalid - cannot be x1 >= x2 or y1 >= y2!"
          end

          max_width, max_height = BitmapMaker.dimensions_for(hwnd)
          if x2 > max_width || y2 > max_height
            raise "specified coordinates (#{specified_coordinates}) are invalid - maximum x2: #{max_width} and y2: #{max_height}!"
          end
        end
      end
    end
  end
end
