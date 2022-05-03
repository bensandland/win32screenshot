require 'win32/screenshot'
require 'benchmark'
require 'fileutils'
include Benchmark

FileUtils.rm_rf('img')
FileUtils.mkdir('img')

Dir.chdir("c:/program files/Internet Explorer") { IO.popen(".\\iexplore about:blank") }

Benchmark.benchmark(CAPTION, 20, FORMAT, ">total:", ">avg:") do |x|
   # Take a screenshot of the window with the specified title
   title = x.report("title:") {Win32::Screenshot::Take.of(:window, title: "Blank Page - Internet Explorer").write("img/image_title.bmp")}

   # Take a screenshot of the whole desktop area, including all monitors if multiple are connected
   desktop = x.report("desktop:") {Win32::Screenshot::Take.of(:desktop).write("img/image_desktop.png")}

   # Take a screenshot of the foreground window
   fg = x.report("foreground:") {Win32::Screenshot::Take.of(:foreground).write("img/image_window.png")}

   # Take a screenshot of the foreground window, and writing over previous image if it exists
   fg_overwrite = x.report("foreground_overwrite:") {Win32::Screenshot::Take.of(:foreground).write!("img/image.png")}

   # Take a screenshot of the specified window with title matching the regular expression
   title_regex = x.report("title_regex:") {Win32::Screenshot::Take.of(:window, title: /internet/i).write("img/image_regex.jpg")}

   # Take a screenshot of the window with the specified handle
   window = RAutomation::Window.new(:title => /internet explorer/i)
   handle = x.report("handle:") {Win32::Screenshot::Take.of(:window, hwnd: window.hwnd).write("img/image_handle.gif")}

   # Take a screenshot of the child window with the specified internal class name
   child = x.report("child:") {Win32::Screenshot::Take.of(:window, :rautomation => RAutomation::Window.new(hwnd: window.hwnd).
           child(class: "Internet Explorer_Server")).write("img/image_class.png")}

   [
           title + desktop + fg + fg_overwrite + title_regex + handle + child,
           (title + desktop + fg + fg_overwrite + title_regex + handle + child) / 7
   ]
end

system("taskkill /PID #{RAutomation::Window.new(:title => /internet explorer/i).pid} > nul")
