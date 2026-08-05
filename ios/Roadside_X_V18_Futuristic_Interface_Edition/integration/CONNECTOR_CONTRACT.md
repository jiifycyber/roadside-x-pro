# Standard connector contract
Each approved partner adapter should implement:
- authenticate()
- receiveDispatch(payload)
- acceptDispatch(reference)
- declineDispatch(reference, reason)
- sendTechnicianAssignment(reference, technician)
- sendEta(reference, eta)
- sendLocation(reference, lat, lng, timestamp)
- sendStatus(reference, status)
- submitCompletion(reference, proof)
- submitInvoice(reference, invoice)
- verifyWebhookSignature(headers, body)
