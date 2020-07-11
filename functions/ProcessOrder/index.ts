import { AzureFunction, Context } from "@azure/functions"
import * as pg from "pg"

const serviceBusQueueTrigger: AzureFunction = async function (context: Context, order: any): Promise<void> {
    context.log('ServiceBus queue trigger function processed message', order);

    const client = new pg.Client()
    await client.connect()
    const res = await client.query('SELECT NOW()')
    context.log(res)
    await client.end()

};

export default serviceBusQueueTrigger;
