using Stipple, StippleUI, StippleCharts

using DataFrames

data = DataFrame(Costs = [44, 55, 13, 43, 22])
labels = ["Team A", "Team B", "Team C", "Team D", "Team E"]
chart_width = 500
# data2 = DataFrame(Costs = [21, 99, 13, 21, 70])
barchart = [PlotSeries("name", PlotData(data.Costs))]
piechart = data.Costs
plot_options_bar = PlotOptions(;
    chart_type = :bar,
    chart_width,
    labels,
)

plot_options_pie = PlotOptions(;
    chart_type = :pie,
    chart_width,
    chart_animations_enabled = true,
    stroke_show = false,
    labels,
)

@reactive! mutable struct Example <: ReactiveModel
    plot_options::R{PlotOptions} = plot_options_pie
    chart::R{Union{Vector,Vector{PlotSeries}}} = piechart

    drawer::R{Bool} = false
    show_bar::R{Bool} = false
    show_plot::R{Bool} = false
end

Stipple.register_components(Example, StippleCharts.COMPONENTS)
model = Stipple.init(Example)

function switch_plots(model)
    println("hello")
    if model.show_bar[]
        model.plot_options[] = plot_options_bar
        model.chart[] = barchart
    else
        model.plot_options[] = plot_options_pie
        model.chart[] = piechart
    end
    return model
end

function handlers(model)
    on(model.isready) do ready
        ready || return
        notify(model.plot_options)        
    end
    on(model.show_bar) do _
        switch_plots(model)     
    end
    on(model.show_plot) do _
        "helloooooo"     
    end
    model
end

function ui(model)
    dashboard(model, [
        StippleUI.Layouts.layout([
            header([
                    btn("",icon="menu", @click("drawer = ! drawer"))
                    title("Example App")
            ])
            drawer(side="left", v__model="drawer", [
                list([
                    btn("", style = "width: 30px;",icon="menu", @click("drawer = ! drawer"))
                    item([
                        item_section(icon("bar_chart"), :avatar)
                        item_section("Bar")
                    ], :clickable, :v__ripple, @click("show_bar = true, drawer = false"))
                    item([
                        item_section(icon("pie_chart"), :avatar)
                        item_section("Circle")
                    ], :clickable, :v__ripple, @click("show_bar = false, drawer = false"))
                ])
            ])
            h3("Example Plot")
            row(
                StippleCharts.plot(:chart, options = :plot_options), @iif(:show_plot)
            )
            row(
                # cell(class = "st-module", [plot(:piechart_, options! = "plot_options")]),
                [radio("Pie plot", :show_bar, val = 0),
                radio("Bar plot", :show_bar, val = "true"),
                btn("Show plot", color = "secondary", @click("show_plot = true"))],@els(:show_plot)
            )
        ])
    ])
end

route("/") do
    model |> handlers |> ui |> html
end

up(8080, open_browser = true)