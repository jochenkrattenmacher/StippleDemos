using Stipple, StippleUI, StippleCharts

using DataFrames

data = DataFrame(Costs = [44, 55, 13, 43, 22])
# data2 = DataFrame(Costs = [21, 99, 13, 21, 70])

@reactive! mutable struct Example <: ReactiveModel
    plot_options_bar::R{PlotOptions} = PlotOptions(
        chart_type = :bar,
        labels = ["Team A", "Team B", "Team C", "Team D", "Team E"],
        yaxis_max = 60,
        yaxis_min = 0,
        ), READONLY
    barchart::R{Vector{PlotSeries}} = [PlotSeries("name", PlotData(data.Costs))]

    plot_options_pie::R{PlotOptions} = PlotOptions(
        chart_type = :pie,
        chart_width = 500,
        chart_animations_enabled = true,
        stroke_show = false,
        labels = ["Slice A", "Slice B"],
      )
    piechart_::R{Vector} = [23, 55]

    drawer::R{Bool} = false
    show_bar::R{Bool} = true
end

Stipple.register_components(Example, StippleCharts.COMPONENTS)
model = Stipple.init(Example)

function handlers(model)
    on(model.isready) do ready
        ready || return
        notify(model.plot_options_bar)        
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
                    ], :clickable, :v__ripple, @click("show_bar = true"))
                    item([
                        item_section(icon("pie_chart"), :avatar)
                        item_section("Circle")
                    ], :clickable, :v__ripple, @click("show_bar = false"))
                ])
            ])
            h3("Example Plot")
            row(
                StippleCharts.plot(:barchart, options = :plot_options_bar), @iif(:show_bar)
            )
            row(
                # cell(class = "st-module", [plot(:piechart_, options! = "plot_options")]),
                StippleCharts.plot(:piechart_, options = :plot_options_pie), @els(:show_bar)
            )
        ])
    ])
end

route("/") do
    model |> handlers |> ui |> html
end

up(8080, open_browser = true)