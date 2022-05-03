# Win32::Screenshot

*   http://github.com/jarmo/win32screenshot


## DESCRIPTION

Capture Screenshots on Windows with Ruby to bmp, gif, jpg or png formats!

## INSTALL

    gem install win32screenshot

## SYNOPSIS

    require 'win32/screenshot'

    # Take a screenshot of the window with the specified title
    Win32::Screenshot::Take.of(:window, title: "Windows Internet Explorer").write("image.bmp")

    # Take a screenshot of the whole desktop area, including all monitors if multiple are connected
    Win32::Screenshot::Take.of(:desktop).write("image.png")

    # Take a screenshot of the foreground window
    Win32::Screenshot::Take.of(:foreground).write("image.png")

    # Take a screenshot of the foreground window, and writing over previous image if it exists
    Win32::Screenshot::Take.of(:foreground).write!("image.png")

    # Take a screenshot of the specified window with title matching the regular expression
    Win32::Screenshot::Take.of(:window, title: /internet/i).write("image.jpg")

    # Take a screenshot of the window with the specified handle
    Win32::Screenshot::Take.of(:window, hwnd: 123456).write("image.gif")

    # Take a screenshot of the child window with the specified internal class name
    Win32::Screenshot::Take.of(:rautomation, RAutomation::Window.new(hwnd: 123456).
                              child(class: "Internet Explorer_Server")).write("image.png")

    # Use the bitmap blob for something else
    image = Win32::Screenshot::Take.of(:window, hwnd: 123456)
    image.height # => height of the image
    image.width  # => width of the image
    image.bitmap # => bitmap blob

## Benchmark

### Previous - pure bit_blt
                               user     system      total        real
    title:                 0.375000   0.219000   0.594000 (  0.692421)
    desktop:               0.063000   0.109000   0.172000 (  0.774872)
    foreground:            0.047000   0.031000   0.078000 (  0.328633)
    foreground_overwrite:  0.015000   0.094000   0.109000 (  0.342176)
    title_regex:           0.031000   0.031000   0.062000 (  0.256067)
    handle:                0.094000   0.031000   0.125000 (  0.431312)
    child:                 0.063000   0.016000   0.079000 (  0.512474)
    >total:                0.688000   0.531000   1.219000 (  3.337955)
    >avg:                  0.098286   0.075857   0.174143 (  0.476851)

### Updated - print_window & bit_blt

                               user     system      total        real
    title:                 0.422000   0.156000   0.578000 (  0.687059)
    desktop:               0.078000   0.078000   0.156000 (  0.757428)
    foreground:            0.047000   0.062000   0.109000 (  0.340794)
    foreground_overwrite:  0.047000   0.032000   0.079000 (  0.352732)
    title_regex:           0.031000   0.078000   0.109000 (  0.274622)
    handle:                0.032000   0.047000   0.079000 (  0.434795)
    child:                 0.015000   0.031000   0.046000 (  0.565335)
    >total:                0.672000   0.484000   1.156000 (  3.412767)
    >avg:                  0.096000   0.069143   0.165143 (  0.487538)

## Copyright

Copyright (c) Jarmo Pertman, Aslak Hellesøy. See LICENSE for details.
