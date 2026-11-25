import secrets
import sqlite3
from functools import wraps
from pathlib import Path

from flask import Flask, g, jsonify, request
from flask_cors import CORS
from werkzeug.security import check_password_hash, generate_password_hash

BANCO = Path(__file__).parent / "pokedex.db"

app = Flask(__name__)
# Libera chamadas vindas do navegador (o app Flutter web roda em outra origem).
CORS(app)


# ---------------------------------------------------------------------------
# Banco de dados (SQLite)
# ---------------------------------------------------------------------------

def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(BANCO)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA foreign_keys = ON")
    return g.db


@app.teardown_appcontext
def fechar_db(_erro):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def criar_tabelas():
    db = sqlite3.connect(BANCO)
    db.executescript(
        """
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL UNIQUE,
            senha_hash TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS sessoes (
            token TEXT PRIMARY KEY,
            usuario_id INTEGER NOT NULL
                REFERENCES usuarios(id) ON DELETE CASCADE,
            criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS favoritos (
            usuario_id INTEGER NOT NULL
                REFERENCES usuarios(id) ON DELETE CASCADE,
            pokemon_id INTEGER NOT NULL,
            nome TEXT NOT NULL,
            nota TEXT NOT NULL DEFAULT '',
            criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (usuario_id, pokemon_id)
        );
        """
    )
    db.close()


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

def erro(mensagem, codigo):
    return jsonify({"erro": mensagem}), codigo


def favorito_para_dict(linha):
    return {
        "pokemon_id": linha["pokemon_id"],
        "nome": linha["nome"],
        "nota": linha["nota"],
        "criado_em": linha["criado_em"],
    }


def nova_sessao(usuario_id):
    token = secrets.token_hex(32)
    db = get_db()
    db.execute(
        "INSERT INTO sessoes (token, usuario_id) VALUES (?, ?)",
        (token, usuario_id),
    )
    db.commit()
    return token


def exige_login(funcao):
    """Rotas protegidas: exige 'Authorization: Bearer <token>' válido."""

    @wraps(funcao)
    def interna(*args, **kwargs):
        cabecalho = request.headers.get("Authorization", "")
        if not cabecalho.startswith("Bearer "):
            return erro("Token ausente.", 401)
        token = cabecalho[len("Bearer "):].strip()
        linha = get_db().execute(
            "SELECT usuario_id FROM sessoes WHERE token = ?", (token,)
        ).fetchone()
        if linha is None:
            return erro("Token inválido.", 401)
        g.usuario_id = linha["usuario_id"]
        g.token = token
        return funcao(*args, **kwargs)

    return interna


# ---------------------------------------------------------------------------
# Autenticação
# ---------------------------------------------------------------------------

@app.post("/registro")
def registrar():
    dados = request.get_json(silent=True) or {}
    usuario = str(dados.get("usuario", "")).strip().lower()
    senha = str(dados.get("senha", ""))

    if not 3 <= len(usuario) <= 30:
        return erro("O usuário deve ter de 3 a 30 caracteres.", 400)
    if len(senha) < 6:
        return erro("A senha deve ter pelo menos 6 caracteres.", 400)

    db = get_db()
    try:
        cursor = db.execute(
            "INSERT INTO usuarios (nome, senha_hash) VALUES (?, ?)",
            (usuario, generate_password_hash(senha)),
        )
        db.commit()
    except sqlite3.IntegrityError:
        return erro("Esse usuário já existe.", 409)

    token = nova_sessao(cursor.lastrowid)
    return jsonify({"token": token, "usuario": usuario}), 201


@app.post("/login")
def entrar():
    dados = request.get_json(silent=True) or {}
    usuario = str(dados.get("usuario", "")).strip().lower()
    senha = str(dados.get("senha", ""))

    linha = get_db().execute(
        "SELECT id, senha_hash FROM usuarios WHERE nome = ?", (usuario,)
    ).fetchone()
    # Mesma mensagem para usuário inexistente e senha errada.
    if linha is None or not check_password_hash(linha["senha_hash"], senha):
        return erro("Usuário ou senha incorretos.", 401)

    token = nova_sessao(linha["id"])
    return jsonify({"token": token, "usuario": usuario})


@app.post("/logout")
@exige_login
def sair():
    db = get_db()
    db.execute("DELETE FROM sessoes WHERE token = ?", (g.token,))
    db.commit()
    return "", 204


# ---------------------------------------------------------------------------
# Favoritos (sempre do usuário logado)
# ---------------------------------------------------------------------------

@app.get("/favoritos")
@exige_login
def listar_favoritos():
    linhas = get_db().execute(
        "SELECT * FROM favoritos WHERE usuario_id = ? ORDER BY rowid",
        (g.usuario_id,),
    ).fetchall()
    return jsonify([favorito_para_dict(l) for l in linhas])


@app.post("/favoritos")
@exige_login
def adicionar_favorito():
    dados = request.get_json(silent=True) or {}
    pokemon_id = dados.get("pokemon_id")
    nome = str(dados.get("nome", "")).strip()

    # bool também é int em Python, por isso o teste extra.
    if not isinstance(pokemon_id, int) or isinstance(pokemon_id, bool):
        return erro("pokemon_id deve ser um número inteiro.", 400)
    if pokemon_id <= 0 or not nome:
        return erro("Informe pokemon_id positivo e nome.", 400)

    db = get_db()
    try:
        db.execute(
            "INSERT INTO favoritos (usuario_id, pokemon_id, nome) "
            "VALUES (?, ?, ?)",
            (g.usuario_id, pokemon_id, nome),
        )
        db.commit()
    except sqlite3.IntegrityError:
        return erro("Esse Pokémon já está nos favoritos.", 409)

    linha = db.execute(
        "SELECT * FROM favoritos WHERE usuario_id = ? AND pokemon_id = ?",
        (g.usuario_id, pokemon_id),
    ).fetchone()
    return jsonify(favorito_para_dict(linha)), 201


@app.put("/favoritos/<int:pokemon_id>")
@exige_login
def editar_favorito(pokemon_id):
    dados = request.get_json(silent=True) or {}
    nota = str(dados.get("nota", "")).strip()
    if len(nota) > 200:
        return erro("A nota pode ter no máximo 200 caracteres.", 400)

    db = get_db()
    cursor = db.execute(
        "UPDATE favoritos SET nota = ? WHERE usuario_id = ? AND pokemon_id = ?",
        (nota, g.usuario_id, pokemon_id),
    )
    db.commit()
    if cursor.rowcount == 0:
        return erro("Favorito não encontrado.", 404)

    linha = db.execute(
        "SELECT * FROM favoritos WHERE usuario_id = ? AND pokemon_id = ?",
        (g.usuario_id, pokemon_id),
    ).fetchone()
    return jsonify(favorito_para_dict(linha))


@app.delete("/favoritos/<int:pokemon_id>")
@exige_login
def remover_favorito(pokemon_id):
    db = get_db()
    cursor = db.execute(
        "DELETE FROM favoritos WHERE usuario_id = ? AND pokemon_id = ?",
        (g.usuario_id, pokemon_id),
    )
    db.commit()
    if cursor.rowcount == 0:
        return erro("Favorito não encontrado.", 404)
    return "", 204


criar_tabelas()

if __name__ == "__main__":
    # Servidor de desenvolvimento: somente para uso local.
    app.run(debug=True, port=5000)