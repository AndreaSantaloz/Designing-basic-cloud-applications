const express = require('express');
const serverless = require('serverless-http');
const AWS = require('aws-sdk');

const app = express();
app.use(express.json());

// CORS PARA EL HTML FRONT QUE TIENES
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "*");
  res.header("Access-Control-Allow-Headers", "*");
  next();
});

// Configurar DynamoDB
const dynamodb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.DB_DYNAMONAME || 'users';

// Obtener todos los usuarios
app.get('/users', async (req, res) => {
    try {
        const params = { TableName: TABLE_NAME };
        const result = await dynamodb.scan(params).promise();
        res.json({ success: true, data: result.Items, count: result.Count });
    } catch (error) {
        res.status(500).json({ success:false, error:'Error interno del servidor', details:error.message });
    }
});

// Obtener usuario por ID
app.get('/users/:id', async (req, res) => {
    try {
        const params = { TableName: TABLE_NAME, Key:{ user_id:req.params.id } };
        const result = await dynamodb.get(params).promise();
        if(result.Item) res.json({ success:true, data:result.Item });
        else res.status(404).json({ success:false, error:'Usuario no encontrado' });
    } catch (error) {
        res.status(500).json({ success:false, error:'Error interno del servidor', details:error.message });
    }
});

// Crear usuario
app.post('/users', async (req, res) => {
    try{
        const {nombre,email}=req.body;
        if(!nombre || !email) return res.status(400).json({success:false,error:'Nombre y email requeridos'});
        const userId=Date.now().toString();
        const nuevoUsuario={user_id:userId,nombre,email,fecha_creacion:new Date().toISOString()};
        await dynamodb.put({TableName:TABLE_NAME,Item:nuevoUsuario}).promise();
        res.status(201).json({success:true,data:nuevoUsuario,message:'Usuario creado exitosamente'});
    }catch(error){
        res.status(500).json({success:false,error:'Error interno del servidor',details:error.message});
    }
});

// Actualizar usuario
app.put('/users/:id', async (req, res) => {
    try{
        const {nombre,email}=req.body;
        if(!nombre||!email) return res.status(400).json({success:false,error:'Nombre y email requeridos'});
        
        const params={
          TableName:TABLE_NAME,
          Key:{user_id:req.params.id},
          UpdateExpression:'SET #nm=:n,#em=:e,#fa=:f',
          ExpressionAttributeNames:{
            '#nm':'nombre',
            '#em':'email',
            '#fa':'fecha_actualizacion'
          },
          ExpressionAttributeValues:{
            ':n':nombre,
            ':e':email,
            ':f':new Date().toISOString()
          },
          ReturnValues:'ALL_NEW'
        };
        const result=await dynamodb.update(params).promise();
        res.json({success:true,data:result.Attributes,message:'Usuario actualizado exitosamente'});
    }catch(error){
        res.status(500).json({success:false,error:'Error interno del servidor',details:error.message});
    }
});

// Eliminar usuario
app.delete('/users/:id', async (req, res) => {
    try{
        const getParams={TableName:TABLE_NAME,Key:{user_id:req.params.id}};
        const existe = await dynamodb.get(getParams).promise();
        if(!existe.Item) return res.status(404).json({success:false,error:'Usuario no encontrado'});
        await dynamodb.delete(getParams).promise();
        res.json({success:true,message:'Usuario eliminado exitosamente',data:existe.Item});
    }catch(error){
        res.status(500).json({success:false,error:'Error interno del servidor',details:error.message});
    }
});

module.exports.handler = serverless(app);
