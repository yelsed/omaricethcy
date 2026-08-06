# gloed — landscape wallpapers

Drop **wide** images here (width >= height). They go on the landscape monitor
untouched, and `omaricethcy-companions` builds a tall version of each for the
portrait monitor.

Then run:

    omaricethcy-companions gloed

That mirrors the file into `../../backgrounds/` as a symlink — which is the flat
directory Omarchy actually reads — and generates the companion. It also warns if
an image is in the wrong folder for its real shape.

Do not edit `../../backgrounds/`, `../../landscape/` or `../../portrait/` by
hand; all three are generated and will be overwritten.
