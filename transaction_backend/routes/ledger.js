const express = require('express');
const {Blockchain,Block} = require('../models/blockchain');
const { create } = require('ipfs-http-client');
const { fetch } = require('cross-fetch'); 
const axios = require('axios');
const FormData = require('form-data');
const { createClient } =require('@supabase/supabase-js');
require('dotenv').config()

// Supabase Connection
const supabase_url=process.env.SUPABASE_URL
const supabase_anon_key=process.env.SUPABASE_ANON_KEY
const supabase = createClient(supabase_url,supabase_anon_key)


const router = express.Router();
const ledger = new Blockchain;

const ipfs = create({ url: 'http://localhost:5001' ,fetchOptions: {
    duplex: 'true'
  }
}
); // IPFS node URL

// ➡️ Add Transaction
router.post('/add', async (req, res) => {
  const {user_id,sender, receipt_id, amount,campaigns_id} =  req.body;
  // console.log(sender,receipt_id,amount,campaigns_id);
  
  
  if (!user_id || !sender || !receipt_id || !amount || !campaigns_id) {
    return res.status(400).json({ error: 'Invalid transaction data' });
  }

  // Store structured data in IPFS
  const transaction = { user_id,sender, receipt_id, amount,campaigns_id, timestamp: Date.now() };
  // console.log("reached");
  
  // const { cid } = await ipfs.add(JSON.stringify(transaction));
  // const { cid } = await ipfs.add({
  //   content: Buffer.from(JSON.stringify(transaction))
  // });
  

  const formData = new FormData();
  const buffer = Buffer.from(JSON.stringify({ user_id,sender, receipt_id, amount,campaigns_id } ));
  formData.append('file', buffer);
  
  const response = await axios.post('http://localhost:5001/api/v0/add', formData, {
    headers: formData.getHeaders()
  });
  // console.log(response);
  

  // console.log(cid);
  // console.log("reached");
  
  
  // Add to Blockchain
  const blockData = { ipfsHash: response.data.Hash };
  const newBlock = new Block(
    ledger.chain.length,
    Date.now().toString(),
    blockData,
    ledger.getLatestBlock().hash
  );

  // console.log("reached2");


  ledger.addBlock(newBlock);

  const { data, error } = await supabase
  .from('ledger')
  .insert({ipfsHash:response.data.Hash})
  .select()


  return res.status(201).json({
    success:"true",
    message: 'Transaction added',
    ipfsHash: response.data.Hash,
    block: newBlock
  });
});


// Alternative approach using ipfs-http-client
router.get('/transactions', async (req, res) => {
  const transactions=[];

  const { data, error } = await supabase
  .from('ledger')
  .select()
    var dataSize=data.length;
    var transactionData=data;
      
      try {
        for(var i=0;i<dataSize;i++){
        const response = await fetch(`http://localhost:5001/api/v0/cat?arg=${transactionData[i].ipfsHash}`, {
          method: 'POST',
          duplex: 'half'
        });
        
        if (!response.ok) {
          throw new Error(`IPFS error: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.text();
        const transaction = JSON.parse(data);
        transactions.push(transaction);
      }
        return res.json({success:"true",transactions})
      } catch (error) {
        console.log(error);
        
        return res.status(500).json({success:"false"})
      }
    }
  
);

router.get('/transactions/:id', async (req, res) => {
  const transactions=[];

  const { data, error } = await supabase
  .from('ledger')
  .select()
    var dataSize=data.length;
    var transactionData=data;
      
      try {
        for(var i=0;i<dataSize;i++){
        const response = await fetch(`http://localhost:5001/api/v0/cat?arg=${transactionData[i].ipfsHash}`, {
          method: 'POST',
          duplex: 'half'
        });
        
        if (!response.ok) {
          throw new Error(`IPFS error: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.text();
        const transaction = JSON.parse(data);
        if(transaction.campaigns_id===req.params['id']){
          transactions.push(transaction);
        }
      }
        return res.status(200).json(transactions)
      } catch (error) {
        return res.status(500).json({success:"false"})
      }
    }
  
);

router.get('/:uid', async (req, res) => {
  const transactions=[];
  const campaigns = new Set();
  const { data, error } = await supabase
  .from('ledger')
  .select()
    var dataSize=data.length;
    var transactionData=data;
      
      try {
        for(var i=0;i<dataSize;i++){
        const response = await fetch(`http://localhost:5001/api/v0/cat?arg=${transactionData[i].ipfsHash}`, {
          method: 'POST',
          duplex: 'half'
        });
        
        if (!response.ok) {
          throw new Error(`IPFS error: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.text();
        const transaction = JSON.parse(data);
        if(transaction.user_id==req.params['uid']){
          campaigns.add(transaction.campaigns_id);
        }
      }
      for(const x of campaigns){
        transactions.push(x);

      }
        return res.status(200).json({success:true,transactions})
      } catch (error) {
        return res.status(500).json({success:"false"})
      }
    }
  
);

router.get('/transactions/unique/:id', async (req, res) => {
  const transactions=[];
  const campaigns = new Set();
  const { data, error } = await supabase
  .from('ledger')
  .select()
    var dataSize=data.length;
    var transactionData=data;
      
      try {
        for(var i=0;i<dataSize;i++){
        const response = await fetch(`http://localhost:5001/api/v0/cat?arg=${transactionData[i].ipfsHash}`, {
          method: 'POST',
          duplex: 'half'
        });
        
        if (!response.ok) {
          throw new Error(`IPFS error: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.text();
        const transaction = JSON.parse(data);
        if(transaction.campaigns_id===req.params['id']){
          campaigns.add(transaction.user_id);
        }
      }
      for(const x of campaigns){
        transactions.push(x);

      }
        return res.status(200).json({success:true,users:transactions})
      } catch (error) {
        return res.status(500).json({success:"false"})
      }
    }
  
);

module.exports = router;
