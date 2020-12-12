from flask import Flask, json, request
from pymongo import MongoClient, DESCENDING
import datetime


USER = "grupo99"
PASS = "grupo99"
DATABASE = "grupo99"

URL = f"mongodb://{USER}:{PASS}@gray.ing.puc.cl/{DATABASE}?authSource=admin"
client = MongoClient(URL)

db = client[DATABASE]
usuarios = db.usuarios
mensajes = db.mensajes

MESSAGE_KEYS = ['message', 'sender', 'receptant', 'lat', 'long', 'date']
USER_KEYS = ['name', 'age', 'description']

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

# Pagina de inicio
@app.route("/")
def home():
    '''
    Página de inicio
    '''
    return "<h1>¡Hola!</h1><h2>Esta es la API del grupo99-102 para bases de datos 2020-2</h2>"


# GET Básicos
@app.route("/messages")
def all_messages():
    '''
    Devuelve una lista con todos los mensajes
    '''
    try:
        id1 = int(request.args.get('id1', False))
        id2 = int(request.args.get('id2', False))
    except ValueError:
        return json.jsonify({"success": False, "error_message": "Debe ingresar un id numérico"})
    if id1 and id2:
        # Vemos si los usuarios existen
        user1 = list(usuarios.find({"uid": id1}))
        user2 = list(usuarios.find({"uid": id2}))
        if not user1 or not user2:
            return json.jsonify({"success": False, "error_message": "Alguno de los usuarios ingresados no existen"})
        else:
            messages_1to2 = list(mensajes.find({"sender": id1, "receptant": id2}, {"_id": 0}))
            messages_2to1 = list(mensajes.find({"sender": id2, "receptant": id1}, {"_id": 0}))
            return json.jsonify({"success": True, f"messages {id1} to {id2}": messages_1to2, f"messages {id2} to {id1}": messages_2to1})
    else:
        all_messages = list(mensajes.find({}, {"_id": 0}))
        return json.jsonify({"success": True, "messages": all_messages})

@app.route("/messages/<int:mid>")
def message_info(mid):
    '''
    Devuelve una lista con los atributos del mensaje indicado
    '''
    message_info = list(mensajes.find({"mid": mid}, {"_id": 0}))
    if not message_info:
        return json.jsonify({"success": False, "error_message": f"El mensaje con id {mid} no se encuentra en la base de datos"})
    return json.jsonify({"success": True, "message": message_info})

@app.route("/users")
def all_users():
    '''
    Devuelve una lista con todos los usuarios
    '''
    all_users = list(usuarios.find({}, {"_id": 0}))
    return json.jsonify({"success": True, "users": all_users})

@app.route("/users/<int:uid>")
def user_info(uid):
    '''
    Devuelve una lista con los atributos del usuario indicado junto a sus mensajes emitidos
    '''
    user_info = list(usuarios.find({"uid": uid}, {"_id": 0}))
    user_messages = list(mensajes.find({"sender": uid}, {"_id": 0, "message": 1}))
    if not user_info:
        return json.jsonify({"success": False, "error_message": f"El usuario con id {uid} no se encuentra en la base de datos"})
    
    return json.jsonify({"success": True, "user_info": user_info, "user_messages": user_messages})

@app.route("/mongoid/<string:nombre>")
def get_mongoid(nombre):
    '''
    Dado un nombre devuelve el id asignado en la base de datos mongo
    '''
    user = usuarios.find_one({"name": nombre}, {"_id": 0, "uid": 1})
    if not user:
        return json.jsonify({"sucess": False, "error_message": f"El usuario {nombre} no se encuentra en la base de datos"})
    return json.jsonify({"success": True, "mongoid": user["uid"]})

# GET Text-Search
@app.route("/text-search", methods=["GET"])
def text_search():
    if not request.data: # Caso vacio total
        m = list(mensajes.find({}, {"_id": 0}))
        return json.jsonify(m)

    data = request.json
    if not data: # Caso data {}
        m = list(mensajes.find({}, {"_id": 0}))
        return json.jsonify(m)

    desired = []
    required = []
    forbidden = []
    userId = []

    for llave in data:
        if llave == "desired":
            desired = data[llave]
        elif llave == "required":
            required = data[llave]
        elif llave == "forbidden":
            forbidden = data[llave]
        elif llave == "userId":
            userId = data[llave]
        else:
            print("Llave no documentada")

    if not desired and not required and not forbidden and not userId:
        m = list(mensajes.find({}, {"_id": 0}))
        return json.jsonify(m)

    #Se genera string para la consulta
    busqueda_mensajes = []
    #Se elimina el index anterior
    mensajes.drop_indexes()
    mensajes.create_index(keys=[("message", "text")], default_language='none')


    if required:
        required_consulta = "".join([f" \"{palabra}\" " for palabra in required])
    else:
        required_consulta = ""

    if desired:
        desired_consulta = "".join([f" {palabra} " for palabra in desired])
    else:
        desired_consulta = ""

    if required_consulta + desired_consulta != "":
        busqueda_mensajes = list(mensajes.find({"$text": {"$search": required_consulta + desired_consulta}}, {'_id': 0}))

    if userId:
        if list(mensajes.find({"sender": userId}, {'_id': 0})):
            if busqueda_mensajes != []:
                busqueda_usuarios = list(mensajes.find({"sender": userId}, {'_id': 0}))
                busqueda_mensajes = [x for x in busqueda_mensajes if (x in busqueda_usuarios)]
            else:
                busqueda_mensajes = list(mensajes.find({"sender": userId}, {'_id': 0}))

        else:
            return "El usuario introducido no existe"
    if forbidden:
        if required_consulta + desired_consulta == "" and not userId: # caso solo palabras negativas
            forbidden_consulta = "".join([f" {palabra} " for palabra in forbidden])
            busqueda_prohibidos = list(mensajes.find({"$text": {"$search": forbidden_consulta}}, {'_id': 0}))
            busqueda_total = list(mensajes.find({}, {"_id": 0}))
            busqueda_mensajes = [x for x in busqueda_total if (x not in busqueda_prohibidos)]

        else:
            forbidden_consulta = "".join([f" {palabra} " for palabra in forbidden])
            busqueda_prohibidos = list(mensajes.find({"$text": {"$search": forbidden_consulta}},{'_id': 0}))
            busqueda_mensajes = [x for x in busqueda_mensajes if (x not in busqueda_prohibidos)]

    return json.jsonify(busqueda_mensajes)


# POST
@app.route("/messages", methods=['POST'])
def post_message():
    '''
    Agrega un mensaje con los atributos especificados
    '''
    try:
        # Chequeo de body no vacío
        request_dict = request.get_data()
        if not request.get_data():
            err_msg = "Body no recibido"
            return json.jsonify({"success": False, "error_message": err_msg})

        # Chequeo de que todos los atributos estén, esto es lo que vemos con el try
        attributes = {key: request.json[key] for key in MESSAGE_KEYS}

        # Chequeo de validez de atributos
        invalid_attributes = []
        check1 = isinstance(attributes["message"], str)
        if not check1:
            invalid_attributes.append("message")
        check2 = isinstance(attributes["sender"], int)
        if not check2:
            invalid_attributes.append("sender")
        check3 = isinstance(attributes["receptant"], int)
        if not check3:
            invalid_attributes.append("receptant")
        check4 = isinstance(attributes["lat"], float)
        if not check4:
            invalid_attributes.append("lat")
        check5 = isinstance(attributes["long"], float)
        if not check5:
            invalid_attributes.append("long")
        # Código sacado de https://www.tutorialspoint.com/How-to-do-date-validation-in-Python
        date = attributes["date"]
        date_format = '%Y-%m-%d'
        try:
            date_obj = datetime.datetime.strptime(date, date_format)
            check6 = True
        except ValueError:
            check6 = False
            invalid_attributes.append("date")
        
        if check1 and check2 and check3 and check4 and check5 and check6:
            # Chequeo de existencia de usuarios
            sender = list(usuarios.find({"uid": attributes["sender"]}))
            if not sender:
                err_msg = "El usuario indicado como sender no existe"
                return json.jsonify({"success": False, "error_message": err_msg})
            receptant = list(usuarios.find({"uid": attributes["receptant"]}))
            if not receptant:
                err_msg = "El usuario indicado como receptant no existe"
                return json.jsonify({"success": False, "error_message": err_msg})

            next_id = mensajes.find({}, {"mid": 1}).sort('mid', DESCENDING).limit(1)[0]["mid"] + 1
            attributes["mid"] = next_id
            mensajes.insert_one(attributes)
            return json.jsonify({"success": True, "mid": next_id})
        else:
            err_msg = f"Los siguientes valores no son válidos: {', '.join(invalid_attributes)}"
            return json.jsonify({"success": False, "error_message": err_msg})
    except KeyError:
        missing_attributes = list(set(MESSAGE_KEYS) - set(request.json.keys()))
        err_msg = f"Faltan los atributos: {', '.join(missing_attributes)}"
        return json.jsonify({"success": False, "error_message": err_msg})

@app.route("/user", methods=['POST'])
def post_user():
    '''
    Agrega un usuario con los atributos especificados
    '''
    attributes = {key: request.json[key] for key in USER_KEYS}
    next_id = usuarios.find({}, {"uid": 1}).sort('uid', DESCENDING).limit(1)[0]["uid"] + 1
    attributes["uid"] = next_id
    usuarios.insert_one(attributes)
    return json.jsonify({"success": True, "uid": next_id})


# DELETE
@app.route("/message/<int:mid>", methods=['DELETE'])
def delete_message(mid):
    '''
    Elimina el mensaje con la id entregada
    '''
    message = list(mensajes.find({"mid": mid}, {"_id": 0}))
    if not message:
        err_msg = "No existe un mensaje con el id indicado"
        return json.jsonify({"success": False, "error_message": err_msg})

    mensajes.remove({"mid": mid})
    return json.jsonify({"success": True})


if __name__ == "__main__":
    app.run(threaded=True, port=5000)
