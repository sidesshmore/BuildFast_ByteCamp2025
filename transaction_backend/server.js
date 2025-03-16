const express = require('express');
const bodyParser = require('body-parser');
const ledgerRoutes = require('./routes/ledger');
var cors = require('cors')

const app = express();
app.use(cors())

app.use(bodyParser.json());
app.use('/ledger', ledgerRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
