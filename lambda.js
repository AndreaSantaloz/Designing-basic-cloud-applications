const express = require('express');
const serverless = require('serverless-http');

const app = express();

app.use(express.json());

// "Base de datos" en memoria
let usuarios = [
    { id: 1, nombre: "Ana", email: "ana@email.com" },
    { id: 2, nombre: "Carlos", email: "carlos@email.com" }
]
;

// GET /usuarios - Obtener todos
app.get('/usuarios', (req, res) => {
    res.json({ success: true, data: usuarios, count: usuarios.length });
});

// GET /usuarios/:id - Obtener uno
app.get('/usuarios/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const usuario = usuarios.find(u => u.id === id);
    
    if (usuario) {
        res.json({ success: true, data: usuario });
    } else {
        res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }
});

// POST /usuarios - Crear
app.post('/usuarios', (req, res) => {
    const nuevoUsuario = {
        id: usuarios.length + 1,
        nombre: req.body.nombre,
        email: req.body.email
    };
    
    usuarios.push(nuevoUsuario);
    res.status(201).json({ success: true, message: 'Usuario creado', data: nuevoUsuario });
});

// PUT /usuarios/:id - Actualizar
app.put('/usuarios/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const usuarioIndex = usuarios.findIndex(u => u.id === id);
    
    if (usuarioIndex !== -1) {
        usuarios[usuarioIndex] = { ...usuarios[usuarioIndex], ...req.body };
        res.json({ success: true, message: 'Usuario actualizado', data: usuarios[usuarioIndex] });
    } else {
        res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }
});

// DELETE /usuarios/:id - Eliminar
app.delete('/usuarios/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const usuarioIndex = usuarios.findIndex(u => u.id === id);
    
    if (usuarioIndex !== -1) {
        const eliminado = usuarios.splice(usuarioIndex, 1)[0];
        res.json({ success: true, message: 'Usuario eliminado', data: eliminado });
    } else {
        res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }
});
// ✅ SERVIR EL FRONTEND - IMPORTANTE: Usar path.join para Lambda
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'api-frontend.html'));
});


// 🔥 IMPORTANTE: Exportar para Lambda
module.exports.handler = serverless(app);