import json

def lambda_handler(event, context):
    print("Evento recibido en ENTREGAUNOCN:", json.dumps(event))
    
    response = {
        'statusCode': 200,
        'body': json.dumps({
            'message': '¡Hola desde ENTREGAUNOCN! Función Lambda con Docker desplegada exitosamente.',
            'input_event': event,
            'timestamp': context.get_remaining_time_in_millis()
        })
    }
    
    print("Respuesta:", response)
    return response