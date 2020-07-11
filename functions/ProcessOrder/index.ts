import { AzureFunction, Context } from "@azure/functions"
import * as pg from "pg"

const serviceBusQueueTrigger: AzureFunction = async function (context: Context, order: any): Promise<void> {
    context.log('ServiceBus queue trigger function processed message', order);

    const client = new pg.Client()
    await client.connect()

    const text = `
        UPDATE public."Orders"
            SET "Processed" = true
            WHERE "Id" = $1
    `
    const values = [order]
    await client.query(text, values)
    await client.end()
};

export default serviceBusQueueTrigger;
