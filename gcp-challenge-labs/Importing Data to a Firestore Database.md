# Importing Data to a Firestore Database || [GSP642](https://www.cloudskillsboost.google/focuses/8392?parent=catalog) ||

## Solution [here]()

### Set Variables ###
```
export REGION=
```

### Task 1. Set up Firestore in Google Cloud ###
```
gcloud config set project $DEVSHELL_PROJECT_ID
```
```
gcloud firestore databases create --location=$REGION
```
### Task 2. Write database import code ###
#### Clone the repo ####
```
git clone https://github.com/rosera/pet-theory
```
```
cd pet-theory/lab01
```
#### Install google-cloud Node packages ####
```
npm install @google-cloud/firestore
npm install @google-cloud/logging
```
#### Open the file pet-theory/lab01/importTestData.js and Add the following Firestore dependency on line 3 of the file ####
```
const { Firestore } = require("@google-cloud/firestore");
const { Logging } = require('@google-cloud/logging');
```
#### Add the following code underneath line 34 ####
```
async function writeToFirestore(records) {
  const db = new Firestore({  
    // projectId: projectId
  });
  const batch = db.batch()

  records.forEach((record)=>{
    console.log(`Write: ${record}`)
    const docRef = db.collection("customers").doc(record.email);
    batch.set(docRef, record, { merge: true })
  })

  batch.commit()
    .then(() => {
       console.log('Batch executed')
    })
    .catch(err => {
       console.log(`Batch error: ${err}`)
    })
  return
}
```
#### Update the importCsv function to add the function call to writeToFirestore and remove the call to writeToDatabase.####
```
async function importCsv(csvFilename) {
  const parser = csv.parse({ columns: true, delimiter: ',' }, async function (err, records) {
    if (err) {
      console.error('Error parsing CSV:', err);
      return;
    }
    try {
      console.log(`Call write to Firestore`);
      await writeToFirestore(records);
      // await writeToDatabase(records);
      console.log(`Wrote ${records.length} records`);
    } catch (e) {
      console.error(e);
      process.exit(1);
    }
  });

  await fs.createReadStream(csvFilename).pipe(parser);
}
```


node createTestData 1000

node importTestData customers_1000.csv

npm install csv-parse

node createTestData 20000

node importTestData customers_20000.csv
