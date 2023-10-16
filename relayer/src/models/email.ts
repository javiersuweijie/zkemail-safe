import { Schema } from "mongoose";

 
export enum EmailStatus {
    Pending = 'Pending',
    Processed = 'Processed',
    Failed = 'Failed'
}

export interface Email {
    body: string;
    status: EmailStatus;
    subject: string;
    from: string; 
    safe: string;
    circuit_inputs?: string;
}

export const emailSchema = new Schema<Email>({
    body: { type: String, required: true },
    status: { type: String, required: true, default: EmailStatus.Pending },
    subject: { type: String, required: true },
    from: { type: String, required: true },
    safe: { type: String, required: true },
    circuit_inputs: { type: String, required: false },
});
