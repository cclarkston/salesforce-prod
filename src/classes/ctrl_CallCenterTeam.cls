/*created by cm on 2012-2-24
I've built this controller to handle the TeamAssignment VF page.  This page is designed to give 
Call Center supervisors the ability to update the call_center_team__c field in the user table.  Since they
don't have sys admin rights,  this was the only way I could give them access to this ability without setting
up a new custom object to hold the field.
*/
public with sharing class ctrl_CallCenterTeam {
  public Integer page = 1;
  public Integer num_pages = 0;
  Integer record_count;
  Double page_holder;
  Integer records_per_page = 15;
  public boolean display_next = true;
  public boolean display_prev = false;
        public String name_filter {get; set;}
        public boolean getdisplay_next() { return display_next; }
        public boolean getdisplay_prev() { return display_prev; }
        public Integer getpage() {return page;}
        public Integer getnum_pages() {return num_pages;}
        
        public String refreshresults() {
                String query_filter = '%' + name_filter + '%';
    my_users = new User[] {};
        List<User> user_list = [select name,email,lastname,firstname,id,Call_Center_Team__c,user_role__c,bulk_printing__c from User 
      where IsActive = true and name like :query_filter order by name];
        record_count = user_list.size();
        page_holder = Math.ceil(record_count / records_per_page);                               
        num_pages = page_holder.intvalue();
        //only here because for some reason ceil is rounding down!
        if(math.mod(record_count, records_per_page)>0)
          num_pages++;                  
        Integer low_range = (page - 1) * records_per_page;
        Integer high_range = page * records_per_page;
        Integer cnt = 1;
          display_prev = false;
          if(page > 1)
            display_prev = true;
          else
            display_prev = false;
        if(num_pages > 1 && page < num_pages)
          display_next = true;
        else
          display_next = false;  
        for(User this_user : user_list) {
                if(cnt > low_range && cnt <= high_range)
                  my_users.add(this_user);
                cnt++;
        }               
        return null;
        }
        
        public Pagereference user_search() {  
    page = 1;
                refreshresults();
                return null;
        }       
        
        public Pagereference save() {
                update my_users;
                return null;
        }
        
        public Pagereference next() {
                page++;
                refreshresults();
                return null;
        }
        
        public Pagereference prev() {
                page = page - 1;
                refreshresults();
                return null;
        }
        
  User[] my_users;
  public User[] getmy_users() {
        if(my_users==null) {
                my_users = new User[] {};
                List<User> user_list = [select name,email,lastname,firstname,id,Call_Center_Team__c,user_role__c,bulk_printing__c from User
                  where IsActive = true  order by name];
                record_count = user_list.size();
                page_holder = math.ceil((record_count/records_per_page));                               
                num_pages = page_holder.intvalue();
                //only here because for some reason ceil is rounding down!              
                if(math.mod(record_count, records_per_page)>0)
            num_pages++;
                Integer low_range = (page - 1) * records_per_page;
                Integer high_range = page * records_per_page;
                Integer cnt = 1;
                if(page > 1)
                  display_prev = true;
                else
                  display_prev = false;
                if(num_pages > 1 && page < num_pages)
                  display_next = true;
                else
                  display_next = false;  
                for(User this_user : user_list) {
                        if(cnt > low_range && cnt <= high_range)
                          my_users.add(this_user);
                        cnt++;
                }
        }
        return my_users;
  }
}