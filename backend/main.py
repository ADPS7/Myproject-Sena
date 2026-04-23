from flask import Flask
from flask_cors import CORS
from routes import configurar_rutas

app = Flask(__name__)
CORS(app)

configurar_rutas(app)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)