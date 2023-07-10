# from flask import Flask, render_template
# import subprocess

# app = Flask(__name__)

# @app.route('/')
# def home():
#     # Run the correlation.py script
#     subprocess.run(['python', './Correlation.py'])
#     # print("EXECUTED")
#     # Render the index.html template
#     return render_template('index.html')

# if __name__ == '__main__':
#     app.run()



from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('interactive_candlestick_chart.html')

if __name__ == '__main__':
    app.run()