const express = require('express');
const serverless = require('serverless-http');
const path = require('path');

const app = express();

app.use(express.json());


// "Base de datos" en memoria
let usuarios = [
    { id: 1, nombre: "Ana", email: "ana@email.com" },
    { id: 2, nombre: "Carlos", email: "carlos@email.com" }
];

// Middleware CORS para frontend
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    next();
});


// Ruta principal
app.get('/', (req, res) => {
    res.json({ 
        message: 'API funcionando en Lambda',
        timestamp: new Date().toISOString(),
        endpoints: [
            'GET /health',
            'GET /users', 
            'GET /users/:id',
            'POST /users',
            'PUT /users/:id',
            'DELETE /users/:id',
            'GET /app (Frontend)'
        ]
    });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'Lambda funcionando correctamente'
    });
});

// Obtener todos los usuarios
app.get('/users', (req, res) => {
    res.json({
        success: true,
        data: usuarios,
        count: usuarios.length
    });
});

// Obtener usuario por ID
app.get('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const usuario = usuarios.find(u => u.id === id);
    
    if (usuario) {
        res.json({ success: true, data: usuario });
    } else {
        res.status(404).json({ success: false, error: 'Usuario no encontrado' });
    }
});

// Crear usuario
app.post('/users', (req, res) => {
    const { nombre, email } = req.body;
    
    if (!nombre || !email) {
        return res.status(400).json({ success: false, error: 'Nombre y email requeridos' });
    }
    
    const nuevoUsuario = {
        id: usuarios.length + 1,
        nombre,
        email
    };
    
    usuarios.push(nuevoUsuario);
    res.status(201).json({ success: true, data: nuevoUsuario });
});

// Actualizar usuario
app.put('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const usuarioIndex = usuarios.findIndex(u => u.id === id);
    
    if (usuarioIndex === -1) {
        return res.status(404).json({ success: false, error: 'Usuario no encontrado' });
    }
    
    const { nombre, email } = req.body;
    
    if (!nombre || !email) {
        return res.status(400).json({ success: false, error: 'Nombre y email requeridos' });
    }
    
    usuarios[usuarioIndex] = { id, nombre, email };
    res.json({ success: true, data: usuarios[usuarioIndex] });
});

// Eliminar usuario
app.delete('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const usuarioIndex = usuarios.findIndex(u => u.id === id);
    
    if (usuarioIndex === -1) {
        return res.status(404).json({ success: false, error: 'Usuario no encontrado' });
    }
    
    const usuarioEliminado = usuarios.splice(usuarioIndex, 1)[0];
    res.json({ success: true, data: usuarioEliminado });
});

// Exportar para Lambda
module.exports.handler = serverless(app);