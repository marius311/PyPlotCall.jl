module PyPlotCall

using PythonCall

export plt

const plt = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(plt, pyimport("matplotlib.pyplot"))

    if isdefined(Main, :IJulia) && Main.IJulia.inited
        # Main.IJulia.push_preexecute_hook(force_new_fig)
        Main.IJulia.push_postexecute_hook(display_figs)
        Main.IJulia.push_posterror_hook(close_figs)
    end

end

# export documented pyplot API (http://matplotlib.org/api/pyplot_api.html)
const plt_funcs = [
    :acorr, :annotate, :arrow, :autoscale, :autumn, :axhline, :axhspan,
    :axis, :axline, :axvline, :axvspan, :bar, :barbs, :barh, :bone, :box,
    :boxplot, :broken_barh, :cla, :clabel, :clf, :clim, :cohere, :colorbar,
    :colors, :contour, :contourf, :cool, :copper, :csd, :delaxes, :disconnect,
    :draw, :errorbar, :eventplot, :figaspect, :figimage, :figlegend, :figtext,
    :figure, :fill_between, :fill_betweenx, :findobj, :flag, :gca, :gcf, :gci,
    :get_current_fig_manager, :get_figlabels, :get_fignums,
    :get_plot_commands, :ginput, :gray, :grid, :hexbin, :hist, :hist2D, :hlines, :hold,
    :hot, :hsv, :imread, :imsave, :imshow, :ioff, :ion, :ishold, :jet, :legend,
    :locator_params, :loglog, :margins, :matshow, :minorticks_off,
    :minorticks_on, :over, :pause, :pcolor, :pcolormesh, :pie, :pink, :plot,
    :plot_date, :plotfile, :polar, :prism, :psd, :quiver, :quiverkey, :rc,
    :rc_context, :rcdefaults, :rgrids, :savefig, :sca, :scatter, :sci,
    :semilogx, :semilogy, :set_cmap, :setp, :show, :specgram, :spectral,
    :spring, :spy, :stackplot, :stem, :step, :streamplot, :subplot,
    :subplot2grid, :subplot_tool, :subplots, :subplots_adjust, :summer,
    :suptitle, :table, :text, :thetagrids, :tick_params, :ticklabel_format,
    :tight_layout, :title, :tricontour, :tricontourf, :tripcolor, :triplot,
    :twinx, :twiny, :vlines, :waitforbuttonpress, :winter, :xkcd, :xlabel,
    :xlim, :xscale, :xticks, :ylabel, :ylim, :yscale, :yticks
]

for func in plt_funcs
    @eval begin
        export $func
        $func(args...; kwargs...) = plt.$func(args...; kwargs...)
    end
end

# The following pyplot functions must be handled specially since they
# overlap with standard Julia functions:
#          close, connect, fill
import Base: close, fill, step
import Sockets: connect

close(fig::Py) = plt.close(fig)

function display_figs() # called after IJulia cell executes
    fig = gcf()
    isempty(fig.get_axes()) || display(MIME"image/png"(), fig)
    close(fig)
end

function close_figs() # called after error in IJulia cell
    fig = gcf()
    plt.close(fig)
end

end