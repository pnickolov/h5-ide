
define [], ()->

  {
    "payment_purchase"  : { url : "/payment/purchase_page/", params: ["projectId"] }
    "payment_self"      : { url : "/payment/self_page/", params: ["projectId"] }
    "payment_statement" : { url : "/payment/statement_list/", params: ["projectId"] }
    "payment_usage"     : { url : "/payment/usage/", params: ["projectId", "startDate", "endDate"] }
  }
