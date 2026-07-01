import os
from app import create_app


app = create_app()


if __name__ == '__main__':
    host = os.getenv('HOST', '127.0.0.1')
    port = int(os.getenv('PORT', 5000))
    # Em desenvolvimento local, debug=True pode ser mantido ou definido por config
    # O container Docker rodará em produção com debug=False
    app.run(host=host, port=port)
