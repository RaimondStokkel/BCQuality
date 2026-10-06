tableextension 50100 "Sample Contact Customer" extends Customer
{
    fields
    {
        field(50100; "Sample Open Contact Issue"; Boolean)
        {
            Caption = 'Unresolved contact issue';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    procedure OpenContactIssue()
    begin
        "Sample Open Contact Issue" := true;
    end;

    procedure ResolveContactIssue(Email: Text[80])
    begin
        Validate("E-Mail", Email);
        TestField("E-Mail");
        "Sample Open Contact Issue" := false;
    end;
}

tableextension 50101 "Sample Contact Job" extends "Job Queue Entry"
{
    fields
    {
        field(50100; "Sample Account Id"; Guid)
        {
            DataClassification = CustomerContent;
        }
    }
}

codeunit 50100 "Sample Contact Inspection"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
    begin
        Rec.TestField("Recurring Job", false);
        Rec.TestField("Manual Recurrence", false);
        Rec.TestField("Sample Account Id");
        Customer.GetBySystemId(Rec."Sample Account Id");
        if Customer."E-Mail" <> '' then
            exit;

        Customer.OpenContactIssue();
        Customer.Modify(true);
    end;

    procedure HasOpenContactIssue(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        exit(Customer."Sample Open Contact Issue");
    end;

    procedure ResolveContactIssue(CustomerNo: Code[20]; Email: Text[80])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.ResolveContactIssue(Email);
        Customer.Modify(true);
    end;
}
