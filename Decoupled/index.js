const express = require('express');
const serverless = require('serverless-http');
const AWS = require('aws-sdk');

const app = express();
app.use(express.json());

// Configurar DynamoDB
const dynamodb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.DB_DYNAMONAME || 'users';

// Middleware CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-api-key');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    next();
});

// Ruta principal
app.get('/', (req, res) => {
    res.json({ 
        message: 'API funcionando en Lambda con DynamoDB',
        timestamp: new Date().toISOString(),
        table: TABLE_NAME,
        endpoints: [
            'GET /health',
            'GET /users', 
            'GET /users/:id',
            'POST /users',
            'PUT /users/:id',
            'DELETE /users/:id'
        ]
    });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'Lambda funcionando correctamente',
        table: TABLE_NAME
    });
});

// Obtener todos los usuarios
app.get('/users', async (req, res) => {
    try {
        const params = {
            TableName: TABLE_NAME
        };
        
        const result = await dynamodb.scan(params).promise();
        
        res.json({
            success: true,
            data: result.Items,
            count: result.Count
        });
    } catch (error) {
        console.error('Error obteniendo usuarios:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Error interno del servidor',
            details: error.message 
        });
    }
});

// Obtener usuario por ID
app.get('/users/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        
        const params = {
            TableName: TABLE_NAME,
            Key: {
                user_id: userId
            }
        };
        
        const result = await dynamodb.get(params).promise();
        
        if (result.Item) {
            res.json({ success: true, data: result.Item });
        } else {
            res.status(404).json({ success: false, error: 'Usuario no encontrado' });
        }
    } catch (error) {
        console.error('Error obteniendo usuario:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Error interno del servidor',
            details: error.message 
        });
    }
});

// Crear usuario
app.post('/users', async (req, res) => {
    try {
        const { nombre, email } = req.body;
        
        if (!nombre || !email) {
            return res.status(400).json({ 
                success: false, 
                error: 'Nombre y email requeridos' 
            });
        }
        
        const userId = Date.now().toString(); // ID único basado en timestamp
        
        const nuevoUsuario = {
            user_id: userId,
            nombre,
            email,
            fecha_creacion: new Date().toISOString()
        };
        
        const params = {
            TableName: TABLE_NAME,
            Item: nuevoUsuario
        };
        
        await dynamodb.put(params).promise();
        
        res.status(201).json({ 
            success: true, 
            data: nuevoUsuario,
            message: 'Usuario creado exitosamente'
        });
    } catch (error) {
        console.error('Error creando usuario:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Error interno del servidor',
            details: error.message 
        });
    }
});

// Actualizar usuario
app.put('/users/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        const { nombre, email } = req.body;
        
        if (!nombre || !email) {
            return res.status(400).json({ 
                success: false, 
                error: 'Nombre y email requeridos' 
            });
        }
        
        // Verificar que el usuario existe
        const getParams = {
            TableName: TABLE_NAME,
            Key: { user_id: userId }
        };
        
        const usuarioExistente = await dynamodb.get(getParams).promise();
        
        if (!usuarioExistente.Item) {
            return res.status(404).json({ 
                success: false, 
                error: 'Usuario no encontrado' 
            });
        }
        
        const updateParams = {
            TableName: TABLE_NAME,
            Key: { user_id: userId },
            UpdateExpression: 'SET #nombre = :nombre, #email = :email, #fecha_actualizacion = :fecha',
            ExpressionAttributeNames: {
                '#nombre': 'nombre',
                '#email': 'email',
                '#fecha_actualizacion': 'fecha_actualizacion'
            },
            ExpressionAttributeValues: {
                ':nombre': nombre,
                ':email': email,
                ':fecha': new Date().toISOString()
            },
            ReturnValues: 'ALL_NEW'
        };
        
        const result = await dynamodb.update(updateParams).promise();
        
        res.json({ 
            success: true, 
            data: result.Attributes,
            message: 'Usuario actualizado exitosamente'
        });
    } catch (error) {
        console.error('Error actualizando usuario:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Error interno del servidor',
            details: error.message 
        });
    }
});

// Eliminar usuario
app.delete('/users/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        
        // Verificar que el usuario existe
        const getParams = {
            TableName: TABLE_NAME,
            Key: { user_id: userId }
        };
        
        const usuarioExistente = await dynamodb.get(getParams).promise();
        
        if (!usuarioExistente.Item) {
            return res.status(404).json({ 
                success: false, 
                error: 'Usuario no encontrado' 
            });
        }
        
        const deleteParams = {
            TableName: TABLE_NAME,
            Key: { user_id: userId }
        };
        
        await dynamodb.delete(deleteParams).promise();
        
        res.json({ 
            success: true, 
            message: 'Usuario eliminado exitosamente',
            data: usuarioExistente.Item 
        });
    } catch (error) {
        console.error('Error eliminando usuario:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Error interno del servidor',
            details: error.message 
        });
    }
});

// Exportar para Lambda
module.exports.handler = serverless(app);