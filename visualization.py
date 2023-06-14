import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np

x_original = np.array([10, 20, 30, 40])
y1_original = np.array([0.00696055684454756, 0.00604838709677419, 0.006048387, 0.00512295081967213])
y2_original = np.array([0.641, 1.0105, 1.23, 1.8665])

x_interpolated = np.arange(10, 41, 1)
y1_interpolated = np.interp(x_interpolated, x_original, y1_original)
y2_interpolated = np.interp(x_interpolated, x_original, y2_original)

trace1 = go.Scatter(
    x=x_interpolated,
    y=y1_interpolated,
    name='Frequency of Switching Stage'
)
normalized_y1 = [(i - min(y1_interpolated)) / (max(y1_interpolated) - min(y1_interpolated)) for i in y1_interpolated]
trace1.y = normalized_y1

trace2 = go.Scatter(
    x=x_interpolated,
    y=y2_interpolated,
    name='Average Panic/Surge',
    xaxis='x',
    yaxis='y2'
)
normalized_y2 = [(i - min(y2_interpolated)) / (max(y2_interpolated) - min(y2_interpolated)) for i in y2_interpolated]
trace2.y = normalized_y2

data = [trace1, trace2]
layout = go.Layout({"template": 'simple_white',
                    "title": {"text": 'Result Analysis-PN500,BRF50,BRT50,PT10,ST40', "x": 0.4},
                    "xaxis": {"title": {"text": "switch index"}, "tickformat": 'd',
                              "tickmode": "linear", "dtick": 1},
                    "yaxis": {"title": {"text": "frequency"}},
                    "yaxis2": {'anchor': 'x', "overlaying": 'y', "side": 'right',
                               "title": {"text": "number of person"}},
                    "width": 900,
                    "height": 900 * 0.618})

fig = go.Figure(data=data, layout=layout)
fig.show()

