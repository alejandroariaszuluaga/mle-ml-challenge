# mle-ml-challenge
Este repositorio contiene todos los archivos y análisis correspondiente a la solución del challenge para ML Engineer diseñado por LATAM Airlines. El cuaderno de Jupyter `to-expose.ipynb` contiene un análisis inicial no desarrollado por el dueño de este repositorio, y se utilizó como base para la evaluación de otros modelos, proceso el cual se detalla en el cuaderno `improve-model.ipynb`. Allí se realizó una nueva selección de modelo y se generó un archivo el cual se utilizó después para exponerlo a través de una REST API que utiliza como backend una Cloud Function en el proveedor GCP. Este proceso se diseñó utilizando una herramienta de Infraestructura como Código (IaC) conocida como [Terraform](https://www.terraform.io/). Se aclara además, que este reto se desarrolló basado en otro challenge conocido como SRE Challenge, el cual desarrolló el mismo autor de este reto, pero el cual tenía un enfoque distinto, más orientado hacia tareas de DevOps/SRE.


Los pasos a seguir necesarios para desplegar este modelo en GCP son los siguientes:
1. Instalar GCP CLI (https://cloud.google.com/sdk/docs/install)
1. Instalar Terraform CLI (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
1. Autenticar en la cuenta de GCP correspondiente mediante: `gcloud init`
1. Crear un nuevo proyecto de GCP y configurar Terraform para que este utilice estas credenciales, es posible realizar este proceso a través de la consola de comandos siguiendo estos pasos:
```console
PROJECT_ID=myproject-whatever-whatever-whatever
gcloud projects create $PROJECT_ID --set-as-default

gcloud auth application-default login
```

1. Habilitar el cobro de tarifas en GCP para el proyecto creado:
    1. Ir a la consola de Google Cloud
    1. Billing -> Account Management -> My Projects
    1. Click en el botón Actions para el nuevo proyecto y luego seleccionar Change Billing
    1. Seleccionar la cuenta de cobro correspondiente y guardar los cambios

1. Habilitar el uso de la API de GCP para los recursos que se utilizarán en este proyecto, los cuales se enlistan a continuación:
    1. Cloud Functions API
    1. Cloud Logging API
    1. Cloud Pub/Sub API
    1. Cloud Build API

1. Reemplazar los valores en `terraform.tfvars` con el ID del proyecto correspondiente y la región de GCP donde se van a crear estos recursos.

1. Finalmente, desplegar la infraestructura en el proyecto en la nube:
    1. `terraform init`
    1. `terraform plan`
    1. Revisar detalladamente la salida del comando anterior y luego correr `terraform apply --auto-approve`

Se creará un bucket de Cloud Storage donde se almacenarán tanto el código de la Cloud Function (paquete zip) como el archivo de modelo `pickle_model.pkl` para poder cargarlo luego durante el tiempo que corre la función. También se dispondrá la función a través de un endpoint con el formato `https://<gcp-region>-<gcp-project-id>.cloudfunctions.net/<nombre-función>`. Esta función está configurada para manejar solicitudes de tipo POST con un payload basado en forms, a continuación se puede observar un ejemplo sobre cómo correr esta función a través de `curl`, usando comandos de shell (ya autenticados por `gcloud`), así como la respuesta esperada para :

```console
foo@bar:~$ curl -X POST -d 'x=[0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]' -H "Authorization: bearer $(gcloud auth print-identity-token)" https://us-central1-mytestsproject-375819.cloudfunctions.net/function-run-pickle-model

> {"model_prediction":"[1]","received_data":{"x":"[0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]"}}

```

# Estructura del Proyecto

    .
    ├── challenge-files        # Archivos recibidos referentes al reto
    ├── load-tests             # Script con el código del load test (.lua)
    ├── model-files            # Archivo con los datos del modelo de ML generado en el cuaderno `improve-model.ipynb`
    ├── src                    # Archivos fuente de la Cloud Function
    ├── terraform              # Archivos del Terraform IaC para GCP
    ├── improve-model.ipynb    # Cuaderno de Jupyter de análisis y selección de modelo
    ├── load_pickle_model.py   # Script de Python que carga y ejecuta un modelo de formato `.pkl`
    └── README.md

## Despliegue de la Cloud Function
El paquete ZIP del código de la CF será creado por Terraform e incluirá las dependencias especificadas en el archivo `requirements.txt`.

## Archivos del Modelo
El archivo `pickle_model.pkl` que Terraform guardará en el bucket de Cloud Storage para posteriormente ser descargado desde el código fuente de la CF.

## Terraform
Todos los archivos `.tf` relacionados con la IaC en GCP se encuentran aquí. Toda la información relacionada al Terraform State no se subirá a GitHub por motivos de seguridad. Es importante tener en cuenta que el archivo `provider.tf` puede modificarse para almacenar el `.tfstate` de forma remota, esta buena práctica es muy recomendable para proyectos en ambientes de producción.

**IMPORTANTE:** al comenzar a construir esta infraestructura, el usuario debe tener un proyecto existente con la facturación habilitada, así como también las API de los recursos de GCP correspondientes habilitadas (estas NO están habilitadas de forma predeterminada, Terraform mostrará un mensaje de error que proporciona los enlaces correspondientes donde el usuario puede habilitar estas API). Los valores de las variables `terraform.tfvars` deben reemplazarse por el ID del proyecto correspondiente y la región de GCP donde se deben crear estos recursos.

# Load Tests
El directorio de pruebas de carga contiene un script `.lua` simple que fue desarrollado para ser utilizado por [wrk, una herramienta de evaluación comparativa de HTTP](https://github.com/wg/wrk), el `<gcloud-bearer-token >` se debe reemplazar por la salida de `gcloud auth print-identity-token` antes de ejecutar el load test.

Los resultados que se obtuvieron al generar más de 50000 solicitudes (este fue un requisito definido por el desafío, así que sencillamente se probaron distintas configuraciones hasta que se alcanzaron los valors requeridos en el intervalo de tiempo definido) en 50 segundos se pueden observar (y se pueden reproducirse instalando la herramienta `wrk` y ejecutando el script `.lua` en este repositorio) a continuación:

```console
foo@bar: ~/$ ./wrk -t 2 -c 100 -d 50s -s ../mle-ml-challenge/load-tests/hard-coded-token-load-test.lua --latency https://us-central1-mytestsproject-375819.cloudfunctions.net/function-run-pickle-model
Running 50s test @ https://us-central1-mytestsproject-375819.cloudfunctions.net/function-run-pickle-model
  2 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    96.30ms   13.04ms 418.34ms   94.42%
    Req/Sec   520.88     43.16   666.00     87.15%
  Latency Distribution
     50%   93.52ms
     75%   96.97ms
     90%  102.20ms
     99%  161.83ms
  51715 requests in 50.05s, 22.20MB read
Requests/sec:   1033.19
Transfer/sec:    454.09KB
```

# Mejoras de Rendimiento
Existen varios posibles cambios que se pueden implementar para mejorar el rendimiento:

1. Caché del modelo pickle: actualmente, este modelo se carga directamente desde un depósito de Cloud Storage, un método de almacenamiento en caché que pueda entregar este objeto más rápido mejoraría este proceso de carga. Dado que este modelo es constante y no se ha incorporado en un pipeline que lo actualice en algún momento, un caché sería una solución apropiada en este caso.
1. Aumentar los recursos de memoria de la Cloud Function.
1. Aumentar las instancias mínimas de autoscaling de la Cloud Function en respuesta a la carga de solicitud recibida.
1. Redundancia regional, desplegando diferentes funciones en regiones distintas.

### Bearer Token
Al momento de desarrollar este reto, solo el propietario principal de esta función podría generar el bearer token correspondiente que se requiere para ejecutar la CF. Esto se puede modificar para otorgar permisos a un usuario de IAM diferente, de modo que otros usuarios también puedan tener acceso a la API.
