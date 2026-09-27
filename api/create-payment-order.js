// Vercel serverless function: creates a payment order with your gateway.
// This is a STUB — plug in real Razorpay/Stripe credentials as Vercel
// environment variables before going live. Never put secret keys in
// public/ files; they belong here, server-side, only.
//
// Example with Razorpay (uncomment and `npm install razorpay` first):
//
// import Razorpay from 'razorpay';
// const instance = new Razorpay({
//   key_id: process.env.RAZORPAY_KEY_ID,
//   key_secret: process.env.RAZORPAY_KEY_SECRET,
// });

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { amount, orderId } = req.body || {};
  if (!amount || !orderId) {
    return res.status(400).json({ error: 'amount and orderId are required' });
  }

  if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
    return res.status(501).json({
      error: 'Payment gateway not configured. Add RAZORPAY_KEY_ID and ' +
             'RAZORPAY_KEY_SECRET in Vercel → Project Settings → Environment Variables.'
    });
  }

  // Real integration would look like:
  // const gatewayOrder = await instance.orders.create({
  //   amount: Math.round(amount * 100), // paise
  //   currency: 'INR',
  //   receipt: orderId,
  // });
  // return res.status(200).json(gatewayOrder);

  return res.status(501).json({ error: 'Gateway integration not yet implemented.' });
}
