---
layout: post
title: Currency Dropdown Fields in ProcessMaker
tags: [ProcessMaker, How to Guide] 
subclass: 'post tag-content'
categories: 'dipole'
navigation: True
logo: 'assets/images/lbpm_dark_logo.png'
disqus: true
date:   2017-09-03 22:31:01 +0100
---

While building a process recently, there was a requirement to add a currency dropdown for users to select the currency for amount fields. The simple solution will be to add a dropdown field (e.g. `amount_1_cur`) to the form linked to a variable with options for a list of currencies and another field (e.g. `amount_1`) for the amount as shown in the image below.

![Separate Dropdown field Example](/assets/images/posts/currency-dropdown-fields/currency_dropdown_demo_1.png)

####Additional requirements
In this case, the form had about ten amount fields that had to have their own currency selectors. In addition, there were also other requirements, such as 

1. Ability to easily add new currencies to the process in the future
2. The currencies would be classified into local and foreign currencies with some amount fields using only foreign currencies and others using all currencies
3. The dropdown list had to be displayed in a certain order

With these requirements, it is obvious that the initial solution will not be easy to maintain. Adding a new currency will involve updating all the variables in the different forms that use them. Also since the "key" column in the list of options for the variable is set to the ISO code for the currency, we will not be able to enforce the sort order.

####An alternate solution
To meet the requirements identified above and make it easy to maintain, we will use the following ProcessMaker features

1. **PM Tables** - Create a table to store the different currencies with additional columns for classification and sorting
2. **<a href="http://wiki.processmaker.com/3.2/DynaForm_Field_Properties#Array_Variable" target="_blank">Dropdown with Array variable</a>** - Set the dropdown fields to use an array variable as the data source
3. **Trigger** - Update the array variable with the list of currencies in the right order using a trigger when a new case is started.

####Create the Currency PM Table
First, create a PM table named CURRENCY with the following columns. You can also follow along by dowloading the PM table using the link below the tables and importing it into ProcessMaker.

Field Name |Type    |Size |Null | Primary Key | Auto Increment| Description
-----------|--------|-----|-----|-------------|---------------|-------------
CODE       |VARCHAR |5    |No   | Yes         | No |ISO code for the currency e.g. USD
LABEL      |VARCHAR |50   |No   | No          | No |The display name for the currency e.g. US Dollar
SYMBOL     |VARCHAR |5    |Yes  | No          | No | The currency symbol e.g. $
CATEGORY   |BIGINT |2    |No   | No          | No | Indicates if the currency is local or foreign (I use 1 for local and 2 for foreign)
WEIGHT     |BIGINT |11   |No   | No          | No | Used to set the sort order for the currencies

Once the table is created, add the following records. 

CODE|LABEL|SYMBOL|CATEGORY|WEIGHT
----|-----|------|--------|------
NGN|Naira|₦|1|1
USD|US Dollar|$|2|2
EUR|Euro|€|2|3
GBP|British Pounds|£|2|4
ZAR|South African Rand|R|2|5
JPY|Japanese Yen|¥|2|6
CAD|Canadian Dollar|$|2|7

*[Download the CURRENCY PM table](/assets/files/currency.pmt)*

####Setup the array variable
With our PM table in place, the next step is to create the variables that will hold the currencies. In the process, create two  new variables `all_currencies` and `foreign_currencies` with Variable type set to array.

####Create a trigger
Next create a trigger named **SetCurrencies** with the following code

{% highlight php %}
@=all_currencies = array();
@=foreign_currencies = array();
$result = executeQuery("SELECT CODE, concat(CODE, '(', SYMBOL, ')') SYMBOL, CATEGORY FROM PMT_CURRENCY ORDER BY WEIGHT");
if (is_array($result)) {
  foreach ($result as $row) {
    @=all_currencies[] = array($row['CODE'], $row['SYMBOL']);
	if($row['CATEGORY'] == 2){
		@=foreign_currencies[] = array($row['CODE'], $row['SYMBOL']);
	}
  }
}
{% endhighlight %}

####Add currency fields to the form
With the preparatory work done, we can now proceed to add multiple currency fields to our dynaforms. For the purpose of this tutorial, we will add two new amount fields `amount_2` (linked to all currencies) and `amount_3` (linked to foreign currencies) to our dynaform.

<a href="http://wiki.processmaker.com/3.0/Row_Control#Col-Span" target="_blank">Split the row into 2 columns</a> and on the left column, add a dropdown control linked to a variable `amount_2_cur`. In the control properties, set the datasource property to **array variable** and then click the @@ button to set the data variable property to **@@all_currencies** as shown in the image below. Add a textbox control in the right column linked to the `amount_2` variable.

![Set the data source to array variable](/assets/images/posts/currency-dropdown-fields/currency_dropdown_demo_2.png)

Repeat the steps above to another row with the dropdown control on the left linked to the `amount_3_cur` variable and the data varable property set to **@@foreign_currencies**. Add a textbox on the right linked to `amount_3` variable. Save and preview the form.

####Setup the task and preview
To see how all this works, add a task to the process with a start and end event as shown below. Assign the dynaform containing our currency fields as a step in the task and set the **SetCurrencies** trigger to execute **BEFORE** the form. Assign a user to the task so we can test it out.

![Sample task](/assets/images/posts/currency-dropdown-fields/currency_dropdown_demo_3.png)

Start a new case as the assigned user and our currency dropdown field should load as displayed below. We can see that Amount 2 field includes Naira, while Amount 3 does not. Also the currencies are listed in the order specified.

![Preview the dynaform](/assets/images/posts/currency-dropdown-fields/currency_dropdown_demo_4.png)

####Improving the user experience
While we have addressed the requirements, we can make the user experience better by placing the currency dropdowns directly beside the corresponding fields and having them share the same label. To do that, we'll use some JavaScript to tweak the form.

First we change the columns for the currency rows from 2 to 4 (set the col-span property of the row to "3 3 3 3") and place all the fields in the same row. Also remove the currency suffix in the labels of the dropdown fields. Add the JavaScript below to the form and save it.

{% highlight javascript %}
function addCurrencyDropdown(ctrlId){
  $("#"+ctrlId+" > div.col-sm-3").hide();
  $("#"+ctrlId+" > div.col-sm-9").removeClass("col-sm-9 col-md-9 col-lg-9").addClass("col-sm-12");
  $("#"+ctrlId+"_cur > div.col-sm-3").removeClass("col-sm-3 col-md-3 col-lg-3").addClass("col-sm-8");
  $("#"+ctrlId+"_cur > div.pmdynaform-field-control").removeClass("col-sm-9 col-md-9 col-lg-9").addClass("col-sm-4");
}

//Add currency dropdown to currency fields
addCurrencyDropdown("amount_2");
addCurrencyDropdown("amount_3");
{% endhighlight %}

If using ProcessMaker 3.1, the code for the `addCurrencyDropdown` function above (ProcessMaker 3.2) should be changed to the code below as the col-spans of the fields are different.

{% highlight javascript %}
function addCurrencyDropdown(ctrlId){
  $("#"+ctrlId+" > label.col-sm-5").hide();
  $("#"+ctrlId+" > div.col-sm-7").removeClass("col-sm-7 col-md-7 col-lg-7").addClass("col-sm-12");
  $("#"+ctrlId+"_cur > label.col-sm-5").removeClass("col-sm-5 col-md-5 col-lg-5").addClass("col-sm-8");
  $("#"+ctrlId+"_cur > div.pmdynaform-field-control").removeClass("col-sm-7 col-md-7 col-lg-7").addClass("col-sm-4");
}
{% endhighlight %}

The currency fields are now displayed as shown below.

![Improved currency dropdown form](/assets/images/posts/currency-dropdown-fields/currency_dropdown_demo_5.png)

And there you have it. A better looking currency dropdown field that we can readily add new currencies to and reuse multiple times on the form.

*[Download the sample process](/assets/files/Currency_Dropdown_Demo-1.pmx)*