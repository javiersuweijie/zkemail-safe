import { Schema } from "mongoose";

 
export enum EmailStatus {
    Pending = 'Pending',
    Processed = 'Processed',
    Failed = 'Failed'
}

export interface Email {
    type: "APPROVE" | "SEND";
    body: string;
    status: EmailStatus;
    subject: string;
    from: string; 
    safe: string;
    circuit_inputs?: string;
    tx_hash?: string;
}

export const emailSchema = new Schema<Email>({
    type: { type: String, required: true },
    body: { type: String, required: true },
    status: { type: String, required: true, default: EmailStatus.Pending },
    subject: { type: String, required: true },
    from: { type: String, required: true },
    safe: { type: String, required: true },
    circuit_inputs: { type: String, required: false },
    tx_hash: { type: String, required: false },
});
