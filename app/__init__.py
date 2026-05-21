import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager

db = SQLAlchemy()
login_manager = LoginManager()


def create_app(test_config: dict | None = None):
    app = Flask(__name__, instance_relative_config=False)

    from config import config
    env = os.getenv('FLASK_ENV', 'default')
    app.config.from_object(config.get(env, config['default']))

    if test_config:
        app.config.update(test_config)

    db.init_app(app)
    login_manager.init_app(app)
    login_manager.login_view = 'main.login'

    with app.app_context():
        from . import routes  # noqa: F401
        from . import models  # noqa: F401
        app.register_blueprint(routes.bp)
        db.create_all()

    return app
