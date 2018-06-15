public with sharing class ctrl_sales_order {
    public Sales_Order__c sales_order {get; set;}
    public ClearChoice_Part__c searched_part {get; set;}
    public Sales_order_Line_Item__c sol {get;set;}
    public Private_Practice_Payment__c[] payment_list {get; set;}
    public Private_Practice_Payment__c new_payment {get; set;}
    public Boolean modal_display {get;set;}
    public String modal_type {get; set;}
    public String modal_out {get; set;}
    public String display_mode {get; set;}
    public Center_Information__c center;
    public Decimal finance_fee {get; set;}
    public class RefundException extends Exception {}
    private Private_Practice_Patient__c patient;
    public Decimal payment_amount;


    // Alon - Each value in the ClearChoice_Part__c.Type__c picklist should be added to Private_Practice_Payment__c and Sales_Order__c objects.
    // In that case, this payment categories list should start with something to represent the tax fields, like 'Tax', plus the exact picklist values.
    // I'm choosing not to dynamically add the picklist values to avoid problems when the fields have not been added to the relevant objects.
    private Set<String> special_credit_names = new Set<String>{'CareCredit', 'Lending Club'};
    private String[] payment_categories = new String[]{'Tax', 'Dental Product', 'Esthetics Product', 'Esthetics Service'};
    public Map<String, String> payment_fieldnames     = new Map<String, String>{payment_categories[0] => 'Tax_Amount__c',
                                                                                payment_categories[1] => 'Dental_Product_Amount__c',
                                                                                payment_categories[2] => 'Esthetics_Product_Amount__c',
                                                                                payment_categories[3] => 'Esthetics_Service_Amount__c'};
    private Map<String, String> sales_order_fieldnames = new Map<String, String>{payment_categories[0] => 'Tax_Total__c',
                                                                                 payment_categories[1] => 'Dental_Product_Total__c',
                                                                                 payment_categories[2] => 'Esthetics_Product_Total__c',
                                                                                 payment_categories[3] => 'Esthetics_Service_Total__c'};

    public ctrl_sales_order() {
        payment_amount = 0;
        display_mode = 'Edit';
        close_modal();
        modal_type = '';
        ID sales_order_id = apexpages.currentpage().getparameters().get('so_num');
        if(sales_order_id != null) {
            sales_order = current_sales_order(sales_order_id);
            if(sales_order.order_status__c == 'Invoiced') {display_mode = 'View';}
            refresh_payment_list();
        }
    }

            private void initialize_new_payment() {
                new_payment = new Private_Practice_Payment__c(Payment_Date__c = System.today(), CC_Sales_order__c = sales_order.id, Payment_Amount__c = 0.00, Finance_Fee__c = 0.00, Payment_Status__c = 'Collected', Account__c = sales_order.Account__c, Private_Practice_Patient__c = sales_order.Private_Practice_Patient__c);
                for (String fieldname : payment_fieldnames.values()) {new_payment.put(fieldname, 0.00);}
            }

            private Sales_Order__c current_sales_order(ID sales_order_id) {
                return [SELECT s.Shipping_Out_Of_State__c,s.Shipping__c,s.Tax_Total__c, s.Dental_Product_Total__c, s.Esthetics_Product_Total__c, s.Esthetics_Service_Total__c, s.Tax_Rate__c, s.Subtotal__c, s.Private_Practice_Patient__c, s.Private_Practice_Patient__r.Center__c, s.Private_Practice_Patient__r.Series_Balance__c, s.Order_Total__c, s.Order_Status__c, s.Order_Date__c, s.Name, s.Account__c, s.Account__r.Center__c FROM Sales_Order__c s WHERE ID = :sales_order_id];
            }

    public boolean order_not_invoiced() {
        String current_status =  [SELECT  s.Order_Status__c From Sales_Order__c s where id = :sales_order.id].order_status__c;
        if(current_status!='Invoiced')
            return true;
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This order has already been invoiced.  No further changes can be made'));
            return false;
        }
    }

    public void check_for_actions() {
        //check for any actions
        if(apexpages.currentpage().getparameters().get('action') == 'new') {
            try {
                sales_order = new Sales_Order__c(Shipping_Out_Of_State__c = false, Shipping__c = 0, Tax_Total__c = 0, Subtotal__c = 0, Dental_Product_Total__c = 0, Esthetics_Product_Total__c = 0, Esthetics_Service_Total__c = 0, Order_Status__c = 'Open', Order_Date__c = System.today());
                if(apexpages.currentpage().getparameters().get('ppid') != null) {
                    Private_Practice_Patient__c pp = [SELECT ID, Center__r.Tax_Rate__c FROM Private_Practice_Patient__c WHERE ID = :apexpages.currentpage().getparameters().get('ppid')];
                    sales_order.Tax_Rate__c = pp.Center__r.Tax_Rate__c;
                    sales_order.Private_Practice_Patient__c = pp.id;
                }
                else if(apexpages.currentpage().getparameters().get('acid') != null) {
                    Account a = [SELECT id,center__r.Tax_Rate__c FROM Account WHERE id = :apexpages.currentpage().getparameters().get('acid')];
                    sales_order.Tax_Rate__c = a.center__r.Tax_Rate__c;
                    sales_order.Account__c = a.id;
                }
                insert sales_order;
                sales_order = current_sales_order(sales_order.id);
                refresh_payment_list();
            } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to insert new sales order. Please contact IT if you have questions.');}
        }
        center = center();
        if (sales_order.Order_Status__c != 'Invoiced') {initialize_new_payment();}
    }
            private Center_Information__c center() {
                try {
                    ID patient_id  = (sales_order.Private_Practice_Patient__c != null) ? sales_order.Private_Practice_Patient__c : sales_order.Account__c;
                    String table   = (sales_order.Private_Practice_Patient__c != null) ? 'Private_Practice_Patient__c' : 'Account';
                    return database.query('SELECT ID, Name, Street_1__c, Street_2__c, City__c, State__c, Zip_Code__c, Tax_Rate__c FROM Center_Information__c WHERE ID IN (SELECT Center__c FROM ' + table + ' WHERE ID = \'' + patient_id + '\')');
                } catch (Exception e) {
                    add_exception_message(e, 'Encountered an error while trying to lookup the Center. Please contact IT if you have questions.');
                    return null;
                }
            }

    public decimal getorder_total() {
        Decimal shipping_amount = sales_order.Shipping__c == null ? 0 : sales_order.Shipping__c;
        Decimal amount_paid = getamount_paid();

        if(amount_paid != 0.00) {
          Decimal total_taxable = total_taxable();
          Decimal promotion_amount = promotion_amount();
          Decimal tax_total = 0;


          if(total_taxable > 0) {

            tax_total = (total_taxable - promotion_amount) * (center.Tax_Rate__c/100);
          }
          sales_order.Tax_Total__c = tax_total;

          return (tax_total + sales_order.Subtotal__c + shipping_amount).setScale(2);
        }
      return (sales_order.Tax_Total__c + sales_order.Subtotal__c + shipping_amount).setScale(2);
    }

    private Decimal total_taxable() {
      Decimal total_taxable = 0;

      for(Sales_Order_Line_Item__c line_item: getitem_list()) {
        if(line_item.ClearChoice_Center_Part__r.Part__r.Is_Taxable__c) {
          total_taxable += line_item.Quantity__c * line_item.Unit_Price__c;
        }
      }
      return total_taxable;
    }

    private Decimal promotion_amount() {
      Decimal promotion_amount = 0;

      for(Private_Practice_Payment__c payment : payment_list) {
        if (payment.Payment_Type__c == 'Promotion') {
          promotion_amount += payment.Payment_Amount__c;
        }
      }
      return promotion_amount;
    }

    public String getcenter_name() {
        try {
            return center.Name;
        } catch (Exception e) {
            add_exception_message(e, 'Encountered an error while trying to lookup the center\'s name. Please contact IT if you have questions.');
            return null;
        }
    }

    public String getcenter_address() {
        String center_address = '';
        try {
            center_address = center.Street_1__c + '<br />';
            if (center.Street_2__c != null) {
                center_address += center.Street_2__c + '<br />';
                center_address += center.City__c + ', ' + center.State__c + ' ' + center.Zip_Code__c;
            }
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to lookup center address. Please contact IT if you have questions.');}
        return center_address;
    }

    public String getpatient_address() {
        String patient_address = '';
        try {
            if(sales_order.Private_Practice_Patient__c != null) {
                Private_Practice_Patient__c pp = [SELECT p.Street_Address__c, p.State__c, p.Postal_Code__c, p.Full_Name__c, p.City__c FROM Private_Practice_Patient__c p WHERE ID = :sales_order.Private_Practice_Patient__c];
                patient_address = pp.full_name__c + '<br />' + pp.street_address__c + '<br />' + pp.city__c + ', ' + pp.state__c + ' ' + pp.postal_code__c;
            }
            else {
                Account a = [SELECT name,a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCity FROM Account a WHERE ID = :sales_order.account__c];
                patient_address = a.name + '<br />' + a.billingstreet + '<br />' + a.billingcity + ', ' + a.billingstate + ' ' + a.billingpostalcode;
            }
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to lookup patient address. Please contact IT if you have questions.');}
        return patient_address;
    }

    public void oos_save() {
        try {
            update sales_order;
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to update out of state shipping. Please contact IT if you have questions.');}
    }

    //grab line items
    public List<Sales_Order_Line_Item__c> getitem_list() {
        List<Sales_Order_Line_Item__c> so_lines = new List<Sales_Order_Line_Item__c>();
        try {
          so_lines = [SELECT ID, Name, CC_Sales_Order__c, Unit_Cost__c, Unit_Price__c, Quantity__c, Line_Total__c, Line_Tax_Total__c, Line_Note__c, ClearChoice_Center_Part__c, ClearChoice_Center_Part__r.Cost__c, ClearChoice_Center_Part__r.Part__r.Name, ClearChoice_Center_Part__r.Part__r.Part_Description__c, ClearChoice_Center_Part__r.Part__r.UPC__c, ClearChoice_Center_Part__r.Part__r.brand__c, ClearChoice_Center_Part__r.Part__r.type__c, ClearChoice_Center_Part__r.Part__r.Is_Taxable__c, CC_Sales_Order__r.Shipping_Out_Of_State__c, CC_Sales_Order__r.Tax_Rate__c
                      FROM Sales_Order_Line_Item__c
                      WHERE CC_Sales_Order__c = :sales_order.id ORDER BY CreatedDate];
        } catch(Exception e) {add_exception_message(e, 'Encountered an error while trying to retrive sales order line items. Please contact IT if you have questions.');}

        return so_lines;
    }

    public void display_note_form() {
        modal_display = true;
        modal_type = 'new_note';
        modal_out = '';
        sol = new Sales_Order_Line_Item__c (CC_Sales_Order__c = sales_order.id, Line_Note__c = 'Enter notes here', Quantity__c = 0, Unit_Price__c = 0);
    }

    public void display_payment_form() {
        modal_display = true;
        modal_type = 'new_payment';
        modal_out = '';
    }

    public void display_part_search() {
        modal_display = true;
        modal_type = 'part_search';
        modal_out = '';
        searched_part = new ClearChoice_Part__c(Type__c = 'Any', Brand__c = 'Any');
    }

    public void close_modal() {
        modal_display = false;
        modal_out = '';
    }

    public List<SELECTOption> getBrandList() {
        List<SELECTOption> options = new List<SELECTOption>();
        options.add(new SELECTOption('Any','Any Brand'));
        for(Schema.PicklistEntry Value : ClearChoice_Part__c.Brand__c.getDescribe().getPicklistValues()) {
          options.add(new SELECTOption(Value.getvalue(), Value.getLabel()));
        }
        return options;
    }

    public List<SELECTOption> getPTypeList() {
        List<SELECTOption> options = new List<SELECTOption>();
        options.add(new SELECTOption('Any','Products & Services'));
        options.add(new SELECTOption('Product','Product'));
        options.add(new SELECTOption('Service','Service'));
        return options;
    }

    public List<SELECTOption> getvalid_payments() {
        List<SELECTOption> options = new List<SELECTOption>();
        options.add(new SELECTOption('Cash','Cash'));
        options.add(new SELECTOption('Check','Check'));
        options.add(new SELECTOption('Credit','Credit'));
        options.add(new SELECTOption('American Express','American Express'));
        options.add(new SELECTOption('Visa','Visa'));
        options.add(new SELECTOption('Discover','Discover'));
        options.add(new SELECTOption('Master Card','Master Card'));
        options.add(new SELECTOption('Citi','Citi'));
        options.add(new SELECTOption('CareCredit','CareCredit'));
        options.add(new SELECTOption('Lending Club','Lending Club'));
        options.add(new SELECTOption('Series Credit','Series Credit'));
        options.add(new SELECTOption('Promotion','Promotion'));
        options.add(new SELECTOption('BD','BD'));
        options.add(new SELECTOption('Aspire','Aspire'));
        return options;
    }

    public List<SELECTOption> getvalid_payment_status() {
        List<SELECTOption> options = new List<SELECTOption>();
        options.add(new SELECTOption('Collected','Collected'));
        options.add(new SELECTOption('Refund','Refund'));
        return options;
    }

    public ClearChoice_Center_Part__c[] getpart_search_matches() {
        ClearChoice_Center_Part__c[] pmatches = new ClearChoice_Center_Part__c[]{};
        String query_filter                                           = 'WHERE isDeleted = false ';
        if (searched_part.Name != null)                {query_filter += ' AND Part__r.Name LIKE \'%' + searched_part.Name + '%\' ';}
        if (searched_part.UPC__c != null)              {query_filter += ' AND Part__r.UPC__c = \'' + searched_part.UPC__c +'\' ';}
        if (searched_part.Part_Description__c != null) {query_filter += ' AND Part__r.Part_Description__c LIKE \'%' + searched_part.Part_Description__c + '%\' ';}
        if (searched_part.Brand__c != 'Any')           {query_filter += ' AND Part__r.Brand__c = \'' + searched_part.Brand__c +'\' ';}
        if (searched_part.Type__c != 'Any')            {query_filter += ' AND Part__r.RecordType.Name = \'' + searched_part.Type__c + '\' ';}
        query_filter += 'AND Is_Active__c = true AND Center__c = \'' + center.id + '\' ';
        try {
            pmatches = database.query('SELECT ID, Part__r.Name, Part__r.Part_Description__c, Part__r.UPC__c, Part__r.Brand__c, Quantity__c, Cost__c, Price__c, Part__r.RecordType.Name ' +
                                      'FROM ClearChoice_Center_Part__c ' + query_filter + ' LIMIT 40');
        }
        catch (Exception e) {modal_out = 'Error searching parts : ' + e.getmessage();}
        return pmatches;
    }

    public void upc_scan() {
        if(order_not_invoiced())
        try {
            //check to see if we have a UPC match
            if((apexpages.currentpage().getparameters().get('upc') == null ? '' : apexpages.currentpage().getparameters().get('upc')).trim() != '') {
                ClearChoice_Center_Part__c center_part = [SELECT ID, Cost__c, Price__c, Quantity__c, Part__r.RecordType.Name
                                                 FROM ClearChoice_Center_Part__c
                                                 WHERE Part__r.UPC__c = :apexpages.currentpage().getparameters().get('upc')
                                                 AND Is_Active__c = true
                                              ];
                if(center_part != null) {
                    if((center_part.Quantity__c != null && center_part.Quantity__c > 0) || center_part.Part__r.RecordType.Name == 'Service') {
                        Sales_Order_Line_Item__c sl = new Sales_Order_Line_Item__c(Unit_Cost__c = center_part.Cost__c, CC_Sales_Order__c = sales_order.id, ClearChoice_Center_Part__c = center_part.id, Quantity__c = 1, Unit_Price__c = center_part.Price__c);
                        insert sl;
                        calculate_so_totals();
                        close_modal();
                        modal_type = '';
                    }
                    else
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The part you were trying to add to the order had no QTY available.  Please contact IT or adjust the QTY in order to continue'));
                }
                else
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The UPC you scanned did not match any of the parts in the system. Please contact IT if you have questions.'));
            }
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid UPC - Scan ignored'));
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to add the item to the sales order. Please contact IT if you have questions.');}
    }

    public void add_so_part() {
        if(order_not_invoiced())
        try {
            ClearChoice_Center_Part__c center_part = [SELECT ID, Part__r.RecordType.Name, Cost__c, Price__c, Quantity__c
                                                      FROM ClearChoice_Center_Part__c
                                                      WHERE ID = :apexpages.currentpage().getparameters().get('pid')
                                                      AND Is_Active__c = true
                                                    ];
            if((center_part.Quantity__c != null && center_part.Quantity__c > 0) || center_part.Part__r.RecordType.Name == 'Service') {
                Sales_Order_Line_Item__c sl = new Sales_Order_Line_Item__c(Unit_Cost__c = center_part.Cost__c, CC_Sales_Order__c = sales_order.id, ClearChoice_Center_Part__c = center_part.id, Quantity__c = 1, Unit_Price__c = center_part.Price__c);
                insert sl;
                calculate_so_totals();
                close_modal();
                modal_type = '';
            }
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The part you were trying to add to the order had no QTY available. Please contact IT or adjust the QTY in order to continue.'));
            modal_out = '<span class="blank" style="color:red;">There is no QTY available for that item</span>';
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to add the item to the sales order. Please contact IT if you have questions.');}
    }

    public void qty_change() {
        if(order_not_invoiced())
            try {
                Sales_Order_Line_Item__c sl = [SELECT ID, Quantity__c, ClearChoice_Center_Part__c, ClearChoice_Center_Part__r.Quantity__c, ClearChoice_Center_Part__r.Part__r.RecordType.Name
                                               FROM Sales_Order_Line_Item__c
                                               WHERE ID = :apexpages.currentpage().getparameters().get('slid')];
                Integer new_qty = Integer.valueof(apexpages.currentpage().getparameters().get('qty'));
                //make sure this is a service,  or that we have enough qty in stock
                if(new_qty == 0) {
                    //delete the sales order line
                    delete sl;
                    calculate_so_totals();
                }
                else if((sl.ClearChoice_Center_Part__r.Quantity__c != null && sl.ClearChoice_Center_Part__r.Quantity__c >= new_qty) || sl.ClearChoice_Center_Part__r.Part__r.RecordType.Name == 'Service') {
                    sl.Quantity__c = new_qty;
                    update sl;
                    calculate_so_totals();
                }
                else
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is not enough QTY on hand to fill the order. Please contact IT if you have questions.'));
            } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to adjust the item quantity. Please contact IT if you have questions.');}
    }

    public void delete_note() {
        if(order_not_invoiced())
        try {
            Sales_Order_Line_Item__c sl = [SELECT ID FROM Sales_Order_Line_Item__c WHERE ID = :apexpages.currentpage().getparameters().get('slid')];
            delete sl;
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to remove the note. Please contact IT if you have questions.');}
    }

    public void price_change() {
        if(order_not_invoiced())
            try {
                Sales_Order_Line_Item__c sl = [SELECT ID, Unit_Price__c, Quantity__c, ClearChoice_Center_Part__c, ClearChoice_Center_Part__r.Quantity__c, ClearChoice_Center_Part__r.Part__r.Name, ClearChoice_Center_Part__r.Part__r.RecordType.Name
                                               FROM Sales_Order_Line_Item__c
                                               WHERE ID = :apexpages.currentpage().getparameters().get('slid')];
                Decimal new_price = Decimal.valueof(apexpages.currentpage().getparameters().get('price'));
                if(new_price >= 0) {
                    sl.unit_price__c = new_price;
                    update sl;
                    set_series_balance(sl);
                    calculate_so_totals();
                }
                else
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Orders do not currently support a negative price. Please contact IT if you have questions.'));
            } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to adjust the item price. Please contact IT if you have questions.');}
    }

    // When a patient purchases a series of treatments or services they may pay for
    // them upfront. Series_Balance__c stores the total amount paid upfront on
    // the Private_Practice_Patient__c record. Then when a patient receives a
    // treatment or service the Private_Practice_Payment__c type of Series Credit
    // is used and that amount will be deducted from the Series_Balance__c.
    public void set_series_balance(Sales_Order_Line_Item__c item) {
      String item_name = item.ClearChoice_Center_Part__r.Part__r.Name;
      String series_prepaid = 'CC99999';
      fetch_and_assign_patient();

      if(item_name == series_prepaid) {
        Decimal quantity = item.Quantity__c;
        Decimal unit_price = item.Unit_Price__c;
        unit_price = change_unit_price_to_zero_if_null(unit_price);

        patient.Series_Balance__c += (quantity * unit_price);
        update patient;
      }
    }

    private void fetch_and_assign_patient() {
      if(patient == null) {
        Id patient_id = sales_order.Private_Practice_Patient__r.Id;

        patient = [SELECT Series_Balance__c
                   FROM Private_Practice_Patient__c
                   WHERE Id = :patient_id
                 ];
        set_series_balance_to_zero_if_null();
      }
    }

    private void set_series_balance_to_zero_if_null() {
      if(patient.Series_Balance__c == null) {
        patient.Series_Balance__c = 0;
      }
    }

    private Decimal change_unit_price_to_zero_if_null(Decimal unit_price) {
      if(unit_price == null) {
        return 0;
      } else {
        return unit_price;
      }
    }

    public void add_new_note() {
        if(order_not_invoiced())
            try {
                if(sol.line_note__c != null) {
                    insert sol;
                    close_modal();
                    modal_type = '';
                }
                else
                    modal_out = '<span class="blank" style="color:red;">You must enter something for the note field</span>';
            } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to adjust the sales order note. Please contact IT if you have questions.');}
    }

    public void calculate_so_totals() {
        try {
            // Work through all line items and update the sales order totals
            // Then update the payment_list to ensure tax and other payment categories are assigned properly. This solves for the rare case of changing a line item such that the payments then reconcile with the total.
            sales_order.Subtotal__c = 0;
            initialize_sales_order_category_totals(sales_order_fieldnames.values());
            for(Sales_Order_Line_Item__c sl : getitem_list()) {
                sales_order.Subtotal__c += sl.Line_Total__c;
                sales_order.Tax_Total__c += line_tax_total(sl); //sl.Line_Tax_Total__c;
                add_line_total_to_category_total(sl);
            }
            update sales_order;
            update_payment_list();
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to calculate order totals. Please contact IT if you have questions.');}
    }

    private Decimal line_tax_total(Sales_Order_Line_Item__c line_item) {
      Decimal line_total = 0;
      // if taxable add to the Tax_Total__c and store the total taxable value
      // in total_taxable
      if(line_item.ClearChoice_Center_Part__r.Part__r.Is_Taxable__c) {
        line_total = line_item.Quantity__c * line_item.Unit_Price__c;
      }
      // if not shipping out of state, apply sales tax
      if(!line_item.CC_Sales_Order__r.Shipping_Out_Of_State__c) {
        line_total = line_total * (line_item.CC_Sales_Order__r.Tax_Rate__c / 100);
      }

      return line_total;
    }

            private void initialize_sales_order_category_totals(String[] fieldnames) {
                for (String fieldname : fieldnames) {sales_order.put(fieldname, 0);}
            }
            private void add_line_total_to_category_total(Sales_Order_Line_Item__c line_item) {
                String type = [SELECT Type__c FROM ClearChoice_Part__c WHERE ID IN (SELECT Part__c FROM ClearChoice_Center_Part__c WHERE ID = :line_item.ClearChoice_Center_Part__c)].Type__c;

                String fieldname = sales_order_fieldnames.get(type);

                sales_order.put(fieldname, (Decimal)sales_order.get(fieldname) + line_item.Line_Total__c);
            }

    public Decimal getamount_paid() {
      Decimal amount_paid = 0;
      try {
          for(Private_Practice_Payment__c payment : payment_list) {
              if(payment.payment_status__c == 'Collected') {
                  amount_paid += payment.Payment_Amount__c;
              }
              else if(payment.payment_status__c == 'Refund') {
                  amount_paid -= payment.Payment_Amount__c;
              }
          }
      } catch (Exception e) {
        add_exception_message(e, 'Encountered an error while trying to calculate payment totals. Please contact IT if you have questions.');
      }
      return amount_paid.setScale(2);
    }

    public void print_mode() {
        display_mode = 'View';
    }

    public void edit_mode() {
        display_mode = 'Edit';
    }

    public void update_payment_list() {
        try {
            reset_payment_categories_across_payments(payment_list);
            for(Private_Practice_Payment__c payment : payment_list) {distribute_payment_to_all_categories(payment);}
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to update payment details. Please contact IT if you have questions.');}
    }

            private void reset_payment_categories_across_payments(Private_Practice_Payment__c[] payment_list) {
                for (Private_Practice_Payment__c payment : payment_list) {
                    apply_series_credit(payment);
                    check_for_refund_of_special_credit(payment);
                    initialize_payment_categories(payment);
                }
                update payment_list;
            }

    public void refresh_payment_list() {
        try {
            payment_list = database.query('SELECT ' + String.join(payment_fieldnames.values(), ', ') + ', Confirmation_ID__c, Coupon_Type__c, Payment_Type__c, Payment_Status__c, Payment_Status_Formula__c, Payment_Date__c, Payment_Amount__c, Finance_Fee__c, Comission_Doctor__c, CC_Sales_Order__c FROM Private_Practice_Payment__c WHERE CC_Sales_Order__c = \'' + sales_order.id + '\' ORDER BY CreatedDate ASC');
        } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to refresh payment details. Please contact IT if you have questions.');}
    }

    public void add_payment() {
        if(order_not_invoiced())
            try {
                apply_series_credit(new_payment);
                distribute_payment_to_all_categories(new_payment);
                initialize_new_payment();
                close_modal();
                modal_type = '';
            } catch (Exception e) {
                add_exception_message(e, 'Encountered an error while trying to add the payment. Please contact IT if you have questions.');
                modal_out = e.getmessage();
            }
    }

            private void distribute_payment_to_all_categories(Private_Practice_Payment__c payment) {
                initialize_payment_categories(payment);

                Decimal amount_to_distribute = payment.Payment_Amount__c;
                // Distribution priority is assigned by the order of the category list. We refund the most recent distributions first by reversing the list
                String[] categories = (payment.Payment_Status__c != 'Refund') ? payment_categories : reversed_list(payment_categories);
                for (String category : categories) {amount_to_distribute = distribute_payment_to_one_category(payment, category, amount_to_distribute);}
                // try {
                    check_for_refund_of_special_credit(payment);
                    upsert payment;
                // } catch (RefundException error) {add_exception_message(error, error.getMessage());}
                refresh_payment_list();
            }

            private void initialize_payment_categories(Private_Practice_Payment__c payment) {
                for (String fieldname : payment_fieldnames.values()) {
                    payment.put(fieldname, 0);
                }
                if (!is_special_credit(payment))         {payment.Finance_Fee__c = 0;}
                if (payment.Payment_Type__c != 'Coupon') {payment.Coupon_Type__c = null;}
            }

            private String[] reversed_list(String[] a_list) {
                String[] reversed_list = new String[]{};
                for (Integer i = a_list.size() - 1; i >= 0; i--) {reversed_list.add(a_list[i]);}
                return reversed_list;
            }

            private Decimal distribute_payment_to_one_category(Private_Practice_Payment__c payment, String category, Decimal amount_to_distribute) {
                // If money remains to be assigned to the given category (tax, dental product, esthetics service, etc), get the appropriate refund/collection amount
                // Assign that amount to the given category and reduce the remaining distribution by that much
                // Return the remaining distribution amount
                if (amount_to_distribute > 0) {
                    Decimal category_amount;
                    if (payment.Payment_Status__c != 'Refund') {category_amount = category_collection_amount(amount_to_distribute, category);}
                    else                                       {category_amount = category_refund_amount(amount_to_distribute, category);}
                    payment.put(payment_fieldnames.get(category), category_amount);
                    amount_to_distribute -= category_amount;
                }
                return amount_to_distribute;
            }

            private Decimal category_refund_amount(Decimal amount_to_distribute, String category) {
                // If the given category has a positive total amount paid from existing payments, the refund amount will be the lesser of that amount and the amount remaining for distribution
                Decimal refund_amount = 0;
                Decimal category_amount_paid = category_amount_paid(payment_fieldnames.get(category));
                if (category_amount_paid > 0) {refund_amount = Math.min(amount_to_distribute, category_amount_paid);}
                return refund_amount;
            }

            private Decimal category_collection_amount(Decimal amount_to_distribute, String category) {
                // If the given category is not paid off yet, get the amount still due... the category's total (from sales_order) minus the amount collected in that category from existing payments.
                // The amount we want to assign to the category for this payment is the lesser of the amount due and the amount we have left to distribute
                String payment_fieldname     = payment_fieldnames.get(category);
                String sales_order_fieldname = sales_order_fieldnames.get(category);
                Decimal collection_amount = 0;
                if (!amount_is_paid_off(category)) {
                    Decimal amount_due = ((Decimal)sales_order.get(sales_order_fieldname) - category_amount_paid(payment_fieldname));
                    collection_amount = Math.min(amount_to_distribute, amount_due);
                }
                return collection_amount;
            }

            private Boolean amount_is_paid_off(String category) {
                String payment_fieldname     = payment_fieldnames.get(category);
                String sales_order_fieldname = sales_order_fieldnames.get(category);
                return (category_amount_paid(payment_fieldname) >= (Decimal)sales_order.get(sales_order_fieldname));
            }

            private Decimal category_amount_paid(String fieldname) {
                Decimal amount_paid = 0;
                try {
                    // Summarize the category payments for each relevant payment in the db, and include the amount temporarily stored in new_payment prior to its db insertion
                    for(Private_Practice_Payment__c payment : payment_list) {amount_paid = adjusted_amount(payment, fieldname, amount_paid);}
                    amount_paid = adjusted_amount(new_payment, fieldname, amount_paid);
                } catch (Exception e) {add_exception_message(e, 'Encountered an error while trying to calculate ' + fieldname + ' paid so far. Please contact IT if you have questions.');}
                return amount_paid;
            }

            private Decimal adjusted_amount(Private_Practice_Payment__c payment, String fieldname, Decimal amount_paid) {
                if(payment.get(fieldname) != null && payment.get(fieldname) != 0) {
                    if      (payment.Payment_Status__c == 'Collected') {amount_paid += (Decimal)payment.get(fieldname);}
                    else if (payment.Payment_Status__c == 'Refund')  {amount_paid -= (Decimal)payment.get(fieldname);}
                }
                return amount_paid;
            }

            private void check_for_refund_of_special_credit(Private_Practice_Payment__c payment) {
                if(is_special_credit(payment) && payment.Payment_Status__c == 'Refund') {
                    payment.Payment_Status__c = 'Collected';
                    List<String> special_credit_list = new List<String>(special_credit_names);
                    throw new RefundException('Refunding special credit types (' + String.join(special_credit_list, ', ') + ') is not supported.');
                }
            }

            private void apply_series_credit(Private_Practice_Payment__c payment) {
              fetch_and_assign_patient();

              if(payment.Payment_Type__c == 'Series Credit' && payment_amount == 0) {
                update_series_balance(payment);
              } else if (payment.Payment_Type__c == 'Series Credit' && payment_amount > 0) {
                throw new RefundException('You cannot add more than one Series Credit to a single Sales Order. Adjust the Series Credit to the full amount required or create a separate invoice.');
              }
            }

            private void update_series_balance(Private_Practice_Payment__c payment) {
              payment_amount = payment.Payment_Amount__c;

              if(!(patient.Series_Balance__c < payment_amount)) {
                patient.Series_Balance__c -= payment_amount;
                update patient;
              } else {
                payment_amount = 0;
                throw new RefundException('Series Balance insufficient to fund Series Credit. Series Balance is $' + patient.Series_Balance__c);
              }
            }

    public List<Private_Practice_Payment__c> getpayment_details() {
        return payment_list;
    }

    public void invoice_sales_order() {
        Integer line_count = [SELECT COUNT() FROM Sales_Order_Line_Item__c WHERE CC_Sales_Order__c = :sales_order.id];
        if(line_count == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Order has no line items on it. Unable to invoice.'));
            return;
        }
        //need to verify we're allowed to invoice first (team has bypassed this way too often...probably from keeping multiple screens open)
        update_payment_list();
        if(getorder_total() - getamount_paid() <= 0) {
            try {
                //reduce our part qty
                Set<ID> part_list = new Set<ID>();
                Map<ID, Decimal> qty_change = new Map<ID, Decimal>();
                //pull alist of parts on the order - we're going to reset final cost here,  so pull as a list
                List<Sales_Order_Line_Item__c> all_lines = [SELECT ID, CC_Sales_Order__c, Unit_Cost__c, Quantity__c, ClearChoice_Center_Part__c, ClearChoice_Center_Part__r.Cost__c
                                                            FROM Sales_Order_Line_Item__c s
                                                            WHERE ClearChoice_Center_Part__r.Part__r.RecordType.Name = 'Product'
                                                            AND CC_Sales_Order__c = :sales_order.id];
                for(Sales_Order_Line_Item__c so_lines : all_lines) {
                    part_list.add(so_lines.ClearChoice_Center_Part__c);
                    qty_change.put(so_lines.ClearChoice_Center_Part__c, so_lines.Quantity__c);
                    if(so_lines.ClearChoice_Center_Part__r.Cost__c != null) {so_lines.Unit_Cost__c = so_lines.ClearChoice_Center_Part__r.Cost__c;}
                }
                update all_lines;
                //grab those parts and subtract order quantity
                List<ClearChoice_Center_Part__c> center_parts = [SELECT ID, Quantity__c FROM ClearChoice_Center_Part__c WHERE Center__c = :center.id AND ID IN :part_list];
                for(ClearChoice_Center_Part__c center_part : center_parts) {center_part.Quantity__c -=  qty_change.get(center_part.id);}
                update center_parts;
                sales_order.order_status__c = 'Invoiced';
                update sales_order;
                display_mode = 'View';
            } catch (Exception e) {
                add_exception_message(e, 'Encountered an error while trying to invoice the sales order note. Please contact IT if you have questions.');
                modal_out = e.getmessage();
            }
        }
        else
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Order has an outstanding balance, unable to invoice.'));
    }

            private static void add_exception_message(Exception e, String message) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
                ApexPages.addMessages(e);
                // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getStackTraceString()));
            }

    public Boolean gethas_errors() {
        return ApexPages.hasMessages(ApexPages.severity.ERROR);
    }

            private Boolean is_special_credit(Private_Practice_Payment__c payment) {
                return special_credit_names.contains(payment.Payment_Type__c);
            }

    public void set_new_payment_coupon_payment_amount() {
        set_coupon_payment_amount(new_payment);
    }

            private void set_coupon_payment_amount(Private_Practice_Payment__c payment) {
                Set<String> coupons_25 = new Set<String>{'$25 Off', 'Give $25'};
                if (coupons_25.contains(payment.Coupon_Type__c)) {payment.Payment_Amount__c = 25;}
            }

}