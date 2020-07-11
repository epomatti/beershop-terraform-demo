import { AzureFunction, Context } from "@azure/functions"
import * as sql from "mssql"

const config = {
    user: process.env.BEERSHOP_SQLSERVER_USERNAME,
    password: process.env.BEERSHOP_SQLSERVER_PASSWORD,
    server: process.env.BEERSHOP_SQLSERVER_SERVER,
    database: process.env.BEERSHOP_SQLSERVER_DATABASE,
}

const serviceBusQueueTrigger: AzureFunction = async function (context: Context, order: any): Promise<void> {
    context.log('ServiceBus queue trigger function processed message', order);
    const pool = await new sql.ConnectionPool(config).connect()
    try {
        await pool.request()
            .input('id', sql.Char, order)
            .query('update Orders set Processed = 1 where Id = @id')
            .then(result => {
                console.log(result.rowsAffected)
            })
    } finally {
        pool.close()
    }
};

export default serviceBusQueueTrigger;
