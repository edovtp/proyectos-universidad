require "csv"

descripcion = 
"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
"

CSV.foreach("db/comunas_ordenadas.csv") do |row|
    comuna = Commune.new(nombre: row[0])
    comuna.save!
end

interest = Interest.new(nombre: 'Escalada', descripcion: 'Para los amantes de la escalada')
interest.save!

interest = Interest.new(nombre: 'Música', descripcion: 'Para los amantes de la música')
interest.save!

interest = Interest.new(nombre: 'Guitarra', descripcion: 'Para los amantes de la guitarra')
interest.save!

interest = Interest.new(nombre: 'Comida', descripcion: 'Para los amantes de la comida')
interest.save!

interest = Interest.new(nombre: 'Viajar', descripcion: 'Para los amantes de viajar')
interest.save!

interest = Interest.new(nombre: 'Lectura', descripcion: 'Para los amantes de la lectura')
interest.save!

interest = Interest.new(nombre: 'Deporte', descripcion: 'Para los amantes del deporte')
interest.save!

interest = Interest.new(nombre: 'Política', descripcion: 'Para los amantes de la política')
interest.save!

interest = Interest.new(nombre: 'Astronomía', descripcion: 'Para los amantes de la astronomía')
interest.save!

interest = Interest.new(nombre: 'Programación', descripcion: 'Para los amantes de la programación')
interest.save!

interest = Interest.new(nombre: 'Ciencia', descripcion: 'Para los amantes de la ciencia')
interest.save!

interest = Interest.new(nombre: 'Tecnología', descripcion: 'Para los amantes de la tecnología')
interest.save!

interest = Interest.new(nombre: 'Filosofía', descripcion: 'Para los amantes de la filosofía')
interest.save!

user = User.new(email: 'hackerman@uc.cl',
                password: 'hackerman',
                password_confirmation: 'hackerman',
                admin: true,
                nombre: 'Admin',
                genero: 'Otro',
                commune_id: 7)
user.save!


user = User.new(email: 'oscar@uc.cl',
                password: 'oscars810',
                password_confirmation: 'oscars810',
                admin: false,
                nombre: 'Oscar',
                commune_id: 2,
                genero: 'Masculino',
                edad: 20,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(2)
user.interests << Interest.find(3)
user.interests << Interest.find(11)

user = User.new(email: 'benito1234@uc.cl',
                password: '1junio1996',
                password_confirmation: '1junio1996',
                admin: false,
                nombre: 'Benito',
                commune_id: 3,
                genero: 'Masculino',
                edad: 5,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(1)
user.interests << Interest.find(4)

user = User.new(email: 'eduardo@uc.cl',
                password: 'eduardo1234',
                password_confirmation: 'eduardo1234',
                admin: false,
                nombre: 'Eduardo',
                commune_id: 4,
                genero: 'Masculino',
                edad: 20,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(5)
user.interests << Interest.find(8)

user = User.new(email: 'felipe1234@uc.cl',
                password: 'felipe1234',
                password_confirmation: 'felipe1234',
                admin: false,
                nombre: 'Felipe',
                commune_id: 5,
                genero: 'Masculino',
                edad: 20,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(6)
user.interests << Interest.find(7)

user = User.new(email: 'alfonso@uc.cl',
                password: 'alfonso1234',
                password_confirmation: 'alfonso1234',
                admin: false,
                nombre: 'Alfonso',
                commune_id: 4,
                genero: 'Masculino',
                edad: 20,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(9)
user.interests << Interest.find(10)

user = User.new(email: 'mario@uc.cl',
                password: 'mario1234',
                password_confirmation: 'mario1234',
                admin: false,
                nombre: 'Mario',
                commune_id: 4,
                genero: 'Otro',
                edad: 19,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(1)
user.interests << Interest.find(3)
user.interests << Interest.find(5)

user = User.new(email: 'fernando@uc.cl',
                password: 'fernando1234',
                password_confirmation: 'fernando1234',
                admin: false,
                nombre: 'Fernando',
                commune_id: 2,
                genero: 'Masculino',
                edad: 21,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(2)
user.interests << Interest.find(4)
user.interests << Interest.find(6)
user.interests << Interest.find(13)

user = User.new(email: 'ricardo@uc.cl',
                password: 'ricardo1234',
                password_confirmation: 'ricardo1234',
                admin: false,
                nombre: 'Ricardo',
                commune_id: 6,
                genero: 'Masculino',
                edad: 18,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(7)

user = User.new(email: 'benjamin@uc.cl',
                password: 'benjamin1234',
                password_confirmation: 'benjamin1234',
                admin: false,
                nombre: 'Benjamin',
                commune_id: 7,
                genero: 'Otro',
                edad: 19,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(8)

user = User.new(email: 'esteban@uc.cl',
                password: 'esteban1234',
                password_confirmation: 'esteban1234',
                admin: false,
                nombre: 'Esteban',
                commune_id: 8,
                genero: 'Masculino',
                edad: 19,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(9)
user.interests << Interest.find(5)
user.interests << Interest.find(2)
user.interests << Interest.find(1)
user.interests << Interest.find(3)
user.interests << Interest.find(7)

user = User.new(email: "cristina@uc.cl",
                password: 'cristina1234',
                password_confirmation: 'cristina1234',
                admin: false,
                nombre: 'Cristina',
                commune_id: 4,
                genero: 'Otro',
                edad: 24,
                descripcion: descripcion)
user.save!
user.interests << Interest.find(10)
user.interests << Interest.find(1)

user = User.new(email: "valentina@uc.cl",
    password: "valentina1234",
    password_confirmation: "valentina1234",
    admin: false,
    nombre: "Valentina",
    commune_id: 5,
    genero: 'Femenino',
    edad: 20,
    descripcion: descripcion)
user.save!
user.interests << Interest.find(8)
user.interests << Interest.find(4)

user = User.new(email: "daniela@uc.cl",
    password: "daniela1234",
    password_confirmation: "daniela1234",
    admin: false,
    nombre: "Daniela",
    commune_id: 82,
    genero: 'Femenino',
    edad: 23,
    descripcion: descripcion)
user.save!
user.interests << Interest.find(7)
user.interests << Interest.find(3)

user = User.new(email: "fernanda@uc.cl",
    password: "fernanda1234",
    password_confirmation: "fernanda1234",
    admin: false,
    nombre: "Fernanda",
    commune_id: 47,
    genero: 'Femenino',
    edad: 19,
    descripcion: descripcion)
user.save!
user.interests << Interest.find(5)
user.interests << Interest.find(2)

user = User.new(email: "catalina@uc.cl",
    password: "catalina1234",
    password_confirmation: "catalina1234",
    admin: false,
    nombre: "Catalina",
    commune_id: 36,
    edad: 23,
    genero: 'Femenino',
    descripcion: descripcion)
user.save!
user.interests << Interest.find(7)
user.interests << Interest.find(4)
user.interests << Interest.find(2)
user.interests << Interest.find(1)

user = User.new(email: "rorro@uc.cl",
    password: "rorro1234",
    password_confirmation: "rorro1234",
    admin: false,
    nombre: "Rorro",
    commune_id: 162,
    genero: 'Masculino',
    edad: 23,
    descripcion: descripcion)
user.save!
user.interests << Interest.find(5)
user.interests << Interest.find(4)
user.interests << Interest.find(2)
user.interests << Interest.find(7)

user = User.new(email: "camilo@uc.cl",
    password: "camilo1234",
    password_confirmation: "camilo1234",
    admin: false,
    nombre: "Camilo",
    commune_id: 290,
    genero: 'Masculino',
    edad: 25,
    descripcion: descripcion)
user.save!
user.interests << Interest.find(8)
user.interests << Interest.find(9)
user.interests << Interest.find(11)
user.interests << Interest.find(10)

local = Local.new(nombre: "Katako",
                descripcion: "Tenemos preparaciones típicas de la gastronomía internacional, todo vegano. Además de sandwiches, pizza, chorrillana y pastelería en un ambiente amigable",
                aceptado: true,
                telefono: "09 7312 9836",
                direccion: "José Manuel Infante 618, Providencia, Región Metropolitana",
                commune_id: Commune.where("nombre = 'Providencia'")[0].id,
                user_id: 6,
                lat: -33.436837,
                long: -70.621958)
local.save!

local = Local.new(nombre: "Zanzibar",
descripcion: "Premiado por su excelencia, el Restaurant Zanzíbar te ofrece una selección de sus mejores platos para que los puedas disfrutar coḿodamente",
aceptado: true,
telefono: "2 2218 0118",
direccion: "Av San Josemaría Escrivá de Balaguer 6400, Santiago, Vitacura, Región Metropolitana",
commune_id: Commune.where("nombre = 'Las Condes'")[0].id,
user_id: 5,
lat: -33.381529,
long: -70.5817855)
local.save!

local = Local.new(nombre: 'Juan y Medio',
                  descripcion: 'Restaurante de comida tipica chilena. Sabores locales inigualables, o quizás igualables por nuestras abuelas', 
                  aceptado: true, 
                  telefono:  '2 242 131 46',
                  direccion: "Rosario, Rengo, O'Higgins",
                  commune_id: 162, 
                  user_id: 2,
                  lat: -34.3476978,
                  long: -70.8430037)
local.save!

local = Local.new(nombre: 'Pamplona',
                  descripcion: 'Sandwicheria española. Ven a disfrutar los mejores sabores del país ibérico, en territorio chileno, junto a nosotros',
                  aceptado: true,
                  telefono: '2 345 672 49',
                  direccion: 'Exequiel Fernandez 6030, Macul, Región Metropolitana', 
                  commune_id: 162, 
                  user_id: 3,
                  lat:-33.508417, 
                  long:-70.604095)
local.save!

local = Local.new(nombre: 'Taiko',
                  descripcion: 'Tenedor libre de sushi, come todo lo que puedas (o hasta que nosotros te tengamos que parar)',
                  aceptado: false,
                  telefono: '2 634 019 21',
                  direccion: 'Av. Departamental 119, Santiago, San Joaquín, Región Metropolitana', 
                  commune_id: 290, 
                  user_id: 4,
                  lat:-33.507832,
                  long:-70.618347)
local.save!

local = Local.new(nombre: 'Chicken Brother',
                descripcion: 'Totalmente una copia de un local de pollos.',
                aceptado: false,
                telefono: '2 420 549 23',
                direccion: "Av Libertador Bernardo O'Higgins 1111, Santiago, XIII Metropolitana de Santiago",
                commune_id: 307,
                user_id: 8,
                lat:-33.443905, 
                long:-70.651794)
local.save!

local = Local.new(nombre: "Fuente Alemana Alameda",
descripcion: "Fuente de soda familiar, fundada en el año 1970. Local de atención rápida, que todas las familias puedes visitar, con precios accesibles y un grato ambiente",
aceptado: true,
telefono: "2 2639 3231",
direccion: "Av Libertador Bernardo O'Higgins 58, Santiago, Región Metropolitana",
commune_id: Commune.where("nombre = 'Santiago'")[0].id,
user_id: 13,
lat: -33.4376484,
long: -70.6381351)
local.save!

local = Local.new(nombre: 'El Fito',
                descripcion: 'Grandes cantidades de cerveza por bajas cantidades de dinero. Te vas caminando o te vas en ambulancia.',
                aceptado: true,
                telefono: "2 328 340 12",
                direccion: "Vicuña Mackenna 4779, Macul, San Joaquín, Región Metropolitana",
                commune_id: 290,
                user_id: 7,
                lat: -33.498188,
                long: -70.616262)
local.save!


local = Local.new(nombre: 'SubGuay',
    descripcion: 'Sandwiches con todo lo que puedas comer.',
    aceptado: true,
    telefono: '2 340 847 05',
    direccion: "Av Libertador Bernardo O'Higgins 1031-1047, Santiago, Región Metropolitana",
    commune_id: 307,
    user_id: 12,
    lat:-33.443948, 
    long:-70.650323)
local.save!

comentario = Comment.new(contenido: 'Un local bastante variado y con muy buena atención', 
                        user_id: 8,
                        local_id: 1)
comentario.save!

comentario = Comment.new(contenido: 'Posee una comida muy sabrosa, la atencion es 10/10',
                        user_id: 9,
                        local_id: 1)
comentario.save!

comentario = Comment.new(contenido: 'La atencion es muy buena, pero debería existir mas variedad de sandwiches',
                        user_id: 8,
                        local_id: 2)
comentario.save!

comentario = Comment.new(contenido: 'El tiempo de atencion es bastante bueno y los precios estan acorde al nivel de los platos',
                        user_id: 10,
                        local_id: 2)
comentario.save!

comentario = Comment.new(contenido: 'Se demoraban demasiado en atender, pero la comida estaba muy buena',
                         user_id: 11,
                         local_id: 4)
comentario.save!

comentario = Comment.new(contenido: 'Pesima atencion',
    user_id: 11,
    local_id: 5)
comentario.save!

comentario = Comment.new(contenido: 'El mejor lugar para ir con amigos',
    user_id: 10,
    local_id: 7)
comentario.save!

comentario = Comment.new(contenido: 'Atencion lenta, pero la comida vale la pena',
    user_id: 9,
    local_id: 5)
comentario.save!

comentario = Comment.new(contenido: 'Excelentes precios!!!!!!!',
    user_id: 11,
    local_id: 7)
comentario.save!

menu = Menu.new(local_id: 1, nombre: "Sandwich Kinugo", descripcion: "Sandwich de mechada, porotos verdes, rucula, ají verde, tomate y papas al hilo", precio: 4000)
menu.save!

menu = Menu.new(local_id: 1, nombre: "Chorrillana Poñi", descripcion: "Chorrillana con papas fritas, queso fundido, cebolla morada, espárragos, tomate cherry y mechada",
precio: 5500)
menu.save!

menu = Menu.new(local_id: 1, nombre: "Pie de Limón", descripcion: "El mejor pie de limón", precio: 3000)
menu.save!

menu = Menu.new(local_id: 2, nombre: "Satay de Ave", descripcion: "Filetitos de pollo marinados en soya, curcuma y especies", precio: 8000)
menu.save!

menu = Menu.new(local_id: 2, nombre: "Tagine de Osso Buco", descripcion: "Mix de especies marroquíes, pimentones asados y aceitunas", precio: 12500)
menu.save!

menu = Menu.new(local_id: 2, nombre: "Brownie Zanzibar", descripcion: "Lo mas goloso de todos nuestros postres", precio: 3500)
menu.save!

menu = Menu.new(local_id: 3,
                nombre: 'Cazuela',
                descripcion: 'Sopa de verduras con carne de vacuno o de ave',
                precio: 3000)
menu.save!

menu = Menu.new(local_id: 3,
                nombre: 'Empanada de pino',
                descripcion: 'Carne molida con cebolla, aceitunas y huevo cocido, envuelto en masa',
                precio: 1500)
menu.save!    

menu = Menu.new(local_id: 3,
                nombre: 'Porotos',
                descripcion: 'Porotos con tallarines cocidos',
                precio: 3000)
menu.save!

menu = Menu.new(local_id: 4,
                nombre: 'Italiano',
                descripcion: 'Sandwich que posee carne de churrasco/ lomo, palta, tomate y mayonesa',
                precio: 2000)
menu.save!

menu = Menu.new(local_id: 4,
                nombre: 'Barros Luco',
                descripcion: 'Sandwich que posee carne de churrasco/ lomo y queso',
                precio: 1500)
menu.save!

menu = Menu.new(local_id: 4,
                nombre: 'Mega Submarino',
                descripcion: 'Sandwich que posee jamón, tomate, queso, lechuga, pepino, pepinillo y aceitunas',
                precio: 1000)
menu.save!

menu = Menu.new(local_id: 7, nombre: "Churrasco pobre",
descripcion: "El clásico sandwich a lo pobre, clásico de la fuente alemana",
precio: 2000)
menu.save!

menu = Menu.new(local_id: 7, nombre: "Barros luco patrón",
descripcion: "Churrasco, queso, tomate, choclo y mayonesa",
precio: 3000)
menu.save!

menu = Menu.new(local_id: 7, nombre: "Sandwich Pernil",
descripcion: "Pernil de cerdo ahumado y deshuesado a la plancha",
precio: 3500)
menu.save!

menu = Menu.new(local_id: 8,
                nombre: 'Cerveza Baltica 1.5L',
                descripcion: 'Mejor conocida como la Baltiloca.',
                precio: 500)
menu.save!

menu = Menu.new(local_id: 8,
                nombre: 'Papas fritas',
                descripcion: 'Gran porcion de papas para pasar el bajon.',
                precio: 50000)
menu.save!

menu = Menu.new(local_id: 8,
                nombre: 'Becker 1.5L',
                descripcion: 'Para aquellos con gusto más refinado.',
                precio: 1300)
menu.save!


menu = Menu.new(local_id: 9,
    nombre: 'Baratisisisimo 15cm',
    descripcion: 'Incluye cualquier ingrediente de la vitrina.',
    precio: 1700)
menu.save!

menu = Menu.new(local_id: 9,
    nombre: 'Submarino 30cm',
    descripcion: 'Incluye cualquier ingrediente de la vitrina.',
    precio: 3000)
menu.save!

menu = Menu.new(local_id: 9,
                nombre: 'Bebida',
                descripcion: 'Vaso grande de bebida a eleccion',
                precio: 1000)
menu.save!

menu = Menu.new(local_id: 9,
                nombre: 'Combo Clientes Match&Meat',
                descripcion: '2 Submarino + 2 Bebidas + 2 Galletas. Promocion disponible solo para clientes Match&Meat',
                precio: 6500)
menu.save!

valuation = Valuation.new(local_id: 4,
                          local_name: "Pollos Hermanos",
                          user_id: 6,
                          nombre: "Catalina",
                          lucky_id: 16,
                          fecha: "05-04-2020")
valuation.save!

valuation = Valuation.new(local_id: 4,
                          local_name: "Pollos Hermanos",
                          user_id: 7,
                          lucky_id: 13,
                          nombre: "Valentina",
                          fecha: "08-03-2020")
valuation.save!

valuation = Valuation.new(local_id: 2,
                          user_id: 4,
                          puntuacion: 5,
                          realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 2,
                          local_name: "Pamplona",
                          user_id: 6,
                          nombre: "Daniela",
                          lucky_id: 14,
                          fecha: "22-05-2020")
valuation.save!

valuation = Valuation.new(local_id: 1,
                          user_id: 3,
                          puntuacion: 2,
                          realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 1,
                          user_id: 4,
                          puntuacion: 5,
                          realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 2,
                          user_id: 5,
                          puntuacion: 4,
                          realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 5,
    user_id: 11,
    puntuacion: 1,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 7,
    user_id: 10,
    puntuacion: 5,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 5,
    user_id: 9,
    puntuacion: 4,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 7,
    user_id: 11,
    puntuacion: 5,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 4,
    user_id: 9,
    puntuacion: 4,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 4,
    user_id: 8,
    puntuacion: 2,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 1,
    user_id: 7,
    puntuacion: 5,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 1,
    user_id: 2,
    puntuacion: 3,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 2,
    user_id: 6,
    puntuacion: 5,
    realizada: true)
valuation.save!

valuation = Valuation.new(local_id: 2,
    user_id: 7,
    puntuacion: 4,
    realizada: true)
valuation.save!

match_request = MatchRequest.new(
                solicitante_id: 2,
                solicitado_id: 3)
match_request.save!


match_request = MatchRequest.new(
                solicitante_id: 3,
                solicitado_id: 4)
match_request.save!


match_request = MatchRequest.new(
                solicitante_id: 4,
                solicitado_id: 5)
match_request.save!


match_request = MatchRequest.new(
                solicitante_id: 5,
                solicitado_id: 2)
match_request.save!

match_request = MatchRequest.new(
    solicitante_id: 3,
    solicitado_id: 7)
match_request.save!

match_request = MatchRequest.new(
    solicitante_id: 3,
    solicitado_id: 8)
match_request.save!

match_request = MatchRequest.new(
    solicitante_id: 3,
    solicitado_id: 9)
match_request.save!

match_request = MatchRequest.new(
    solicitante_id: 3,
    solicitado_id: 13)
match_request.save!

match_request = MatchRequest.new(
    solicitante_id: 3,
    solicitado_id: 14)
match_request.save!

match = Match.new(
    user1_id: 11,
    user2_id: 2,
    cita_realizada: false)
match.save!

match = Match.new(
    user1_id: 11,
    user2_id: 3,
    cita_realizada: false)
match.save!

match = Match.new(
    user1_id: 11,
    user2_id: 4,
    cita_realizada: false)
match.save!

match = Match.new(
    user1_id: 11,
    user2_id: 5,
    cita_realizada: false)
match.save!

match = Match.new(
    user1_id: 11,
    user2_id: 6,
    cita_realizada: false)
match.save!

match = Match.new(
    user1_id: 11,
    user2_id: 7,
    cita_realizada: false)
match.save!