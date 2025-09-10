public class EzidebitStructs {
    public class Payment {
        public String BankFailedReason;
        public String BankReceiptID;
        public String BankReturnCode;
        public String CustomerName;
        public DateTime DebitDate;
        public String EzidebitCustomerID;
        public String InvoiceID;
        public Double PaymentAmount;
        public String PaymentID;
        public String PaymentMethod;
        public String PaymentReference;
        public String PaymentSource;
        public String PaymentStatus;
        public Double ScheduledAmount;
        public DateTime SettlementDate;
        public Double TransactionFeeClient;
        public Double TransactionFeeCustomer;
        public DateTime TransactionTime;
        public String YourGeneralReference;
        public String YourSystemReference;
    }

    public class RefundPayment {
        public Integer BankReceiptID;
        public Integer RefundPaymentID;
        public String RefundResult;
        public String RefundResultCode;
        public String RefundResultText;
    }

    public class BPayCRN {
        public String BPayBillerCode;
        public String BPayCRN;
    }

    public class CustomerDetails {
        public String AddressLine1;
        public String AddressLine2;
        public String AddressPostCode;
        public String AddressState;
        public String AddressSuburb;
        public DateTime ContractStartDate;
        public String CustomerFirstName;
        public String CustomerName;
        public String Email;
        public String EzidebitCustomerID;
        public String MobilePhone;
        public String PaymentMethod;
        public String PaymentPeriod;
        public String PaymentPeriodDayOfMonth;
        public String PaymentPeriodDayOfWeek;
        public String SmsExpiredCard;
        public String SmsFailedNotification;
        public String SmsPaymentReminder;
        public String StatusCode;
        public String StatusDescription;
        public Integer TotalPaymentsFailed;
        public Double TotalPaymentsFailedAmount;
        public Integer TotalPaymentsSuccessful;
        public Double TotalPaymentsSuccessfulAmount;
        public String YourGeneralReference;
        public String YourSystemReference;
    }
}