class Users:
    def __init__(self):
        self.users_data = {}

    def add_user(self, user_id, username, user_type, id):
        # Store user data in the dictionary
        self.users_data = {
            'UserID': user_id,
            'Username': username,
            'UserType': user_type,
            'ID': id
        }


class Patient:
    def __init__(self, patient_id, user_id, first_name, last_name, date_of_birth, gender, contact_number, email,
                 address):
        self.PatientID = patient_id
        self.UserID = user_id
        self.FirstName = first_name
        self.LastName = last_name
        self.DateOfBirth = date_of_birth
        self.Gender = gender
        self.ContactNumber = contact_number
        self.Email = email
        self.Address = address


class Doctor:
    def __init__(self, doctor_id, user_id, first_name, last_name, specialization_id, contact_number, email, address):
        self.DoctorID = doctor_id
        self.UserID = user_id
        self.FirstName = first_name
        self.LastName = last_name
        self.SpecializationID = specialization_id
        self.ContactNumber = contact_number
        self.Email = email
        self.Address = address


class Appointment:
    def __init__(self, appointment_id, patient_id, doctor_id, appointment_date, reason):
        self.AppointmentID = appointment_id
        self.PatientID = patient_id
        self.DoctorID = doctor_id
        self.AppointmentDate = appointment_date
        self.Reason = reason


class MedicalRecord:
    def __init__(self, record_id, patient_id, doctor_id, record_date, diagnosis):
        self.RecordID = record_id
        self.PatientID = patient_id
        self.DoctorID = doctor_id
        self.RecordDate = record_date
        self.Diagnosis = diagnosis


class Billing:
    def __init__(self, bill_id, record_id, amount, bill_date, payment_status):
        self.BillID = bill_id
        self.RecordID = record_id
        self.Amount = amount
        self.BillDate = bill_date
        self.PaymentStatus = payment_status


class Medicine:
    def __init__(self, medicine_id, medicine_name, manufacturer, expiry_date, dosage_form, active_ingredient, price,
                 stock_quantity=0, storage_conditions=None):
        self.MedicineID = medicine_id
        self.MedicineName = medicine_name
        self.Manufacturer = manufacturer
        self.ExpiryDate = expiry_date
        self.DosageForm = dosage_form
        self.ActiveIngredient = active_ingredient
        self.Price = price
        self.StockQuantity = stock_quantity
        self.StorageConditions = storage_conditions


class Insurance:
    def __init__(self, insurance_id, patient_id, insurance_provider, policy_number, expiry_date, coverage_type,
                 coverage_details, discount):
        self.InsuranceID = insurance_id
        self.PatientID = patient_id
        self.InsuranceProvider = insurance_provider
        self.PolicyNumber = policy_number
        self.ExpiryDate = expiry_date
        self.CoverageType = coverage_type
        self.CoverageDetails = coverage_details
        self.Discount = discount
