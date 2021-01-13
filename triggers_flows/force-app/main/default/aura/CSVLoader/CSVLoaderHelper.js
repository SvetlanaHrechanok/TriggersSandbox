({
    createCSVObject : function(cmp, csv) {
        this.setFileLoaded(cmp, true, "Parse data...");

        var action = cmp.get('c.getCSVObject');
        var csv = cmp.get("v.csvString");

        action.setParams({
            csvStr : csv
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: ' + state);
            if(state == "SUCCESS") {
                var linesOnPage = cmp.get("v.linesOnPage");
                var pageNumber = cmp.get("v.pageNumber");
                var csvObject = response.getReturnValue();
                var lines = csvObject.lines;

                var startIndex = pageNumber * linesOnPage - linesOnPage;
                var endIndex = pageNumber * linesOnPage - 1;

                csvObject.linesOnPage = lines.slice(startIndex, endIndex);

                cmp.set("v.csvObject", csvObject);
                cmp.set("v.saveDisabled", false);
                
                this.setPagesCount(cmp, csvObject.lineCount);
                this.setPaginationBattons(cmp);
                this.goToPage(cmp, 1);

                this.setFileLoaded(cmp, false, "");
                
            }
        });
        $A.enqueueAction(action);
    },

    goToPage : function(cmp, pageNumber){
        var csvObject = cmp.get("v.csvObject");
        var linesOnPage = cmp.get("v.linesOnPage");
        var startIndex = pageNumber * linesOnPage - linesOnPage;
        var endIndex = pageNumber * linesOnPage - 1;

        csvObject.linesOnPage = csvObject.lines.slice(startIndex, endIndex);
        cmp.set("v.csvObject", csvObject);
        cmp.set("v.pageNumber", pageNumber);

        this.setPaginationBattons(cmp);
    },

    setPagesCount : function(cmp, linesCount){
        var linesOnPage = cmp.get("v.linesOnPage");
        
        var pages = (linesCount - linesCount%linesOnPage)/linesOnPage;

        if(linesCount % linesOnPage != 0){
            pages += 1;
        }

        cmp.set("v.pagesCount", pages);
    },

    setPaginationBattons : function(cmp){
        var pagesCount = cmp.get("v.pagesCount");
        var pageNumber = cmp.get("v.pageNumber");

        if(pageNumber == pagesCount){
            cmp.set("v.forwardDisable", true);
        }else{
            cmp.set("v.forwardDisable", false);
        }

        if(pageNumber == 1){
            cmp.set("v.backwardDisable", true);
        }else{
            cmp.set("v.backwardDisable", false);
        }
    },

    setFileLoaded : function(cmp, fileIsLoad, loadingMessage){
        cmp.set("v.isLoad", fileIsLoad);
        cmp.set("v.loadingMessage", loadingMessage);
    },

    saveData : function(cmp){
        var csvObject = cmp.get("v.csvObject");
        var formatedObj = [];

        for(var i = 1; i < csvObject.lines.length; i++){
            var obj = {};
            for(var j = 0; j < csvObject.lines[i].length; j++){
                obj[csvObject.headers[j].columnName] = csvObject.lines[i][j];
            }
            formatedObj.push(obj);
        }

        var action = cmp.get('c.updateLocation360');

        action.setParams({
            jsonData : JSON.stringify(formatedObj)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: ' + state);
            if(state == "SUCCESS") {
                console.log('data saved');
            }
        });
        $A.enqueueAction(action);
    }
})