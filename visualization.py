import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np

x_original = np.array([10, 20, 30, 40])
y1_original = np.array([0.00520291363163371, 0.00572737686139748, 0.00522466039707419, 0.00512163892445582])
y2_original = np.array([1.012, 1.052, 1, 1.319])

x_interpolated = np.arange(10, 41, 1)
y1_interpolated = np.interp(x_interpolated, x_original, y1_original)
y2_interpolated = np.interp(x_interpolated, x_original, y2_original)

trace1 = go.Scatter(
    x=x_interpolated,
    y=y1_interpolated,
    name='Frequency of Switching Stage',
    line = dict(color='rgb(255,0,0)', width=2.5)
)
normalized_y1 = [(i - min(y1_interpolated)) / (max(y1_interpolated) - min(y1_interpolated)) for i in y1_interpolated]
trace1.y = normalized_y1

trace2 = go.Scatter(
    x=x_interpolated,
    y=y2_interpolated,
    name='Average Panic/Surge',
    xaxis='x',
    yaxis='y2',
    line = dict(color='rgb(0,0,255)', width=2.5)
)
normalized_y2 = [(i - min(y2_interpolated)) / (max(y2_interpolated) - min(y2_interpolated)) for i in y2_interpolated]
trace2.y = normalized_y2

data = [trace1, trace2]
layout = go.Layout({"template": 'simple_white',
                    "title": {},
                    "xaxis": {"title": {"text": "Switch Index", 'font': dict(size=24)}, "tickformat": 'd',
                              "tickmode": "linear", "dtick": 5, "tickfont": {"size": 24}},
                    "yaxis": {"title": {"text": "Frequency of Switching Stage", 'font': dict(size=24, color='rgb(255,0,0)'), 'standoff': 10},
                              "tickfont": {"size": 24, "color": 'rgb(255,0,0)'}},
                    "yaxis2": {'anchor': 'x', "overlaying": 'y', "side": 'right',
                               "title": {"text": "Average Panic/Surge", 'font': dict(size=24, color='rgb(0,0,255)')},
                               "tickfont": {"size": 24, "color": 'rgb(0,0,255)'}},
                    "showlegend": False,
                    "width": 700,
                    "height": 700 * 0.9,
                    "autosize": False,
                    "margin": go.layout.Margin(
                        l=100,  # left margin
                        r=50,  # right margin
                        b=100,  # bottom margin
                        t=100,  # top margin
                        pad=10
                    ),
                    "font": {"size": 24}})

fig = go.Figure(data=data, layout=layout)
fig.show()
