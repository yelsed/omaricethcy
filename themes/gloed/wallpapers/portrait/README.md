# gloed — portrait wallpapers

Drop **tall** images here (height > width). They go on the portrait monitor
untouched, and `omaricethcy-companions` builds a wide version of each for the
landscape monitor.

Then run:

    omaricethcy-companions gloed

That mirrors the file into `../../backgrounds/` as a symlink — which is the flat
directory Omarchy actually reads — and generates the companion. It also warns if
an image is in the wrong folder for its real shape.

Do not edit `../../backgrounds/`, `../../landscape/` or `../../portrait/` by
hand; all three are generated and will be overwritten.
