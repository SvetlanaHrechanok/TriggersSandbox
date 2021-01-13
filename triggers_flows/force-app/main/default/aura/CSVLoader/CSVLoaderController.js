({
    handleFilesChange : function(component, event, helper) {
        helper.setFileLoaded(component, true, "Read file data...")

        var file = event.getSource().get("v.files")[0];
        component.set("v.fileName", file.name);
        if(file) {
            console.log("UPLOADED")
            var reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = function(evt) {
                var csv = evt.target.result;
                component.set("v.csvString", csv);

                if(csv != null) {
                    helper.createCSVObject(component);
                }
            }
        }
    },

    handleGetCSV : function(component, event, helper) {
        var csv = component.get("v.csvString");
        if(csv != null) {
            helper.createCSVObject(component, csv);
        }
    },

    cleanData : function(component, event, helper) {
        component.set("v.csvString", null);
        component.set("v.csvObject", null);
        component.set("v.pageNumber", 1);
        component.set("v.pagesCount", 1);
        component.set("v.forwardDisable", true);
        component.set("v.backwardDisable", true);
        component.set("v.fileName", '');
        component.set("v.saveDisabled", true);
    },

    saveData : function(component, event, helper){
        helper.saveData(component);
    },

    getFirstPage : function(component, event, helper) {
        helper.goToPage(component, 1);
    },
    getPrevPage : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        helper.goToPage(component, pageNumber - 1);
    },
    getNextPage : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        helper.goToPage(component, pageNumber + 1);
    },
    getLastPage : function(component, event, helper) {
        var pagesCount = component.get("v.pagesCount");

        helper.goToPage(component, pagesCount);
    },
})