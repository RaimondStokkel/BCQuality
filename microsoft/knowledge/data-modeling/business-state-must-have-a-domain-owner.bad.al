tableextension 50100 "Sample Contact Customer" extends Customer
{
    fields
    {
        field(50100; "Sample Repair Required"; Boolean)
        {
            Caption = 'Contact repair required';
            FieldClass = FlowField;
            CalcFormula = exist("Job Queue Entry" where("Sample Account Id" = field(SystemId),
                                                       "Sample Repair Required" = const(true)));
            Editable = false;
        }
    }
}

tableextension 50101 "Sample Contact Job" extends "Job Queue Entry"
{
    fields
    {
        field(50100; "Sample Account Id"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(50101; "Sample Repair Required"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(SampleContact; "Sample Account Id", "Sample Repair Required") { }
    }
}

codeunit 50100 "Sample Contact Check"
{
    procedure InspectContact(JobId: Guid)
    var
        Customer: Record Customer;
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Get(JobId);
        JobQueueEntry.TestField("Sample Account Id");
        Customer.GetBySystemId(JobQueueEntry."Sample Account Id");
        JobQueueEntry."Sample Repair Required" := Customer."E-Mail" = '';
        JobQueueEntry.Modify(true);
    end;

    procedure NeedsContactRepair(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.CalcFields("Sample Repair Required");
        exit(Customer."Sample Repair Required");
    end;

    procedure RepairContact(CustomerNo: Code[20]; Email: Text[80])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.Validate("E-Mail", Email);
        Customer.TestField("E-Mail");
        Customer.Modify(true);
    end;

    procedure RemoveInactiveAttempt(JobId: Guid)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Get(JobId);
        JobQueueEntry.TestField("Sample Account Id");
        JobQueueEntry.TestField(Status, JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Delete(true);
    end;
}
