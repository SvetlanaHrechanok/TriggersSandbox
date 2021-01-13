import { LightningElement } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import csvLoadLWC from "@salesforce/resourceUrl/csvLoadLWC";

import getAuthList from '@salesforce/apex/CSVCreator.getCSVObject';

export default class CsvLoadLWC extends LightningElement {
  loading = false;
  pageNumber = 1;
  title = "CSV Loader";
  fileName = "";
  fileToParse;
  linesToParse = "1000";
  linesToParseCount;
  linesOnPage = "50";
  lines;
  csvObject;

  connectedCallback() {
    loadStyle(this, csvLoadLWC + "/style.css");
  }

  // on file selected
  async handleFilesChange(event) {
    if (event.target.files.length > 0) {
      this.fileToParse = event.target.files[0];
      this.fileName = event.target.files[0].name;

      if(this.fileToParse){
        const result = await this.load(this.fileToParse);
        this.lines = result.split('\n');
        this.linesToParseCount = this.lines.length;
        this.loading = false;

        this.startParseData();
      }
    }
  }

  // parse part of file data
  startParseData(){
    console.log('start parse');
    var work = true;
    var stringToParse = '';
    var startIndex = 1;
    var endIndex = startIndex + parseInt(this.linesToParse) - 1;

    do{
      if(endIndex > this.lines.length - 1){
        endIndex = this.lines.length - 1;
        work = false;
      }

      console.log('startIndex: ' + startIndex);
      console.log('endIndex: ' + endIndex);
      console.log('work: ' + work);

      stringToParse = this.lines[0] + '\n';

      for(var i = startIndex; i <= endIndex; i++ ){
        stringToParse += this.lines[i] + '\n';
      }

      startIndex = endIndex + 1;
      endIndex = endIndex + parseInt(this.linesToParse) - 1;

      this.sendStringToParse(stringToParse);

    }while(work);
  }

  sendStringToParse(stringToParse){
    csvLoadLWC({csvStr : stringToParse})
      .then(result => {
        console.log(result);
      })
      .catch(error => {
        console.log(error);
      })
  }

  // async loading file
  async load(file) {
    return new Promise((resolve, reject) => {
      this.loading = true;
      const reader = new FileReader();
      reader.onload = function() {
        resolve(reader.result);
      };
      reader.onerror = function() {
        reject(reader.error);
      };
      reader.readAsText(file);
    });
}

  // clear data
  clearData(event) {
    this.fileName = "";
    this.fileToParse = undefined;
  }

  // combobox "Records on page" data
  get linesOnPageSelect() {
    return [
        { label: '25', value: '25' },      
        { label: '50', value: '50' },
        { label: '100', value: '100' },
        { label: '150', value: '150' },
    ];
  }

  // combobox change event
  linesOnPageChange(event) {
    this.linesOnPage = event.detail.value;
  }

  // combobox "Lines to parse" data
  get linesToParseSelect() {
    return [
        { label: '100', value: '100' },      
        { label: '1000', value: '1000' },
        { label: '2500', value: '2500' },
        { label: '5000', value: '5000' },
    ];
  }

  // combobox change event
  linesToParseChange(event) {
    this.linesToParse = event.detail.value;
  }
}