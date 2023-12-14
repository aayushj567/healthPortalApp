import tkinter as tk
from datetime import datetime
from tkinter import ttk, messagebox
import pymysql

from connection import *
from models import *


# Function to connect to MySQL database
def connect_to_database():
    try:
        connection = pymysql.connect(
            host=dbconnect.host,
            user=dbconnect.username,
            password=dbconnect.password,
            database=dbconnect.database
        )
        return connection
    except pymysql.Error as err:
        print(f"Error: {err}")
        return None


def check_empty(*args):
    return all(arg is None or arg == '' for arg in args)


def validate_username_password(username, password):
    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            cursor.execute('SELECT ValidateUsernamePassword(%s, %s) AS result', [username, password])
            result = cursor.fetchone()

            cursor.close()
            connection.close()
            return result[0]
    except pymysql.Error as err:
        print(f"Error: {err}")
        return None


def login(start_up, login_window, username, password):
    # Call the MySQL function to validate the username and password
    result = validate_username_password(username, password)

    # Check the result of the validation
    if result == 1:
        messagebox.showinfo("Login Successful", "Login was successful!")
        try:
            connection = connect_to_database()
            if connection:
                cursor = connection.cursor()
                cursor.callproc("GetAllUserInfo", [username])

                result = cursor.fetchone()

                user_id = result[0]
                username = result[1]
                user_type = result[2]
                uid = result[3]
                user1.add_user(user_id, username, user_type, uid)

                cursor.close()
                connection.close()

                try:
                    login_window.destroy()
                except:
                    pass
                try:
                    start_up.destroy()
                except:
                    pass
                if user1.users_data["UserType"] == "Patient" and user1.users_data["ID"] is not None:
                    display_patient_dashboard()
                elif user1.users_data["UserType"] == "Doctor" and user1.users_data["ID"] is not None:
                    display_doctor_dashboard()
                else:
                    display_user_dashboard()

        except pymysql.Error as err:
            print(f"Error: {err}")

    else:
        messagebox.showerror("Login Failed", "Invalid username or password")


def sign_out(controller_window):
    user1.users_data = {}
    try:
        controller_window.destroy()
    except:
        pass
    display_start_up()


def signup(signup_window, username, password, user_type):
    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            cursor.callproc("CreateUser", (username, password, user_type))
            connection.commit()
            cursor.close()
            connection.close()

            messagebox.showinfo("User Created", "Successfully created new user")

            try:
                signup_window.destroy()
            except:
                pass

    except pymysql.Error as err:
        print(f"Error: {err}")


def create_patient(user_dashboard_window, patient_window, first_name, last_name, date_of_birth, gender, phone_number,
                   email, address):
    # error if any of parameters are empty
    if check_empty(first_name, last_name, date_of_birth, phone_number, email, address, gender):
        messagebox.showerror("Error", "Please fill out all fields")
        return False

    date_of_birth = datetime.strptime(date_of_birth, '%Y-%m-%d')

    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            cursor.callproc("CreatePatient",
                            (user1.users_data["UserID"], first_name, last_name, date_of_birth, gender, phone_number,
                             email,
                             address))
            connection.commit()
            cursor.execute('SELECT PatientID FROM Patients WHERE UserID = %s', user1.users_data["UserID"])
            temp = cursor.fetchone()
            user1.users_data["ID"] = temp[0]
            cursor.close()
            connection.close()
            messagebox.showinfo("Patient Created", "Patient Created Successfully")

            try:
                patient_window.destroy()
                user_dashboard_window.destroy()
            except:
                pass
            display_patient_dashboard()

    except pymysql.Error as err:
        print(f"Error: {err}")
        return False


def create_doctor(user_dashboard_window, doctor_window, first_name, last_name, specialization, phone_number, email,
                  address):
    # error if any of parameters are empty
    if check_empty(first_name, last_name, specialization, phone_number, email, address):
        messagebox.showerror("Error", "Please fill out all fields")
        return False

    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            cursor.callproc("CreateDoctor",
                            (user1.users_data["UserID"],
                             first_name,
                             last_name,
                             specialization,
                             phone_number,
                             email,
                             address))
            connection.commit()
            cursor.execute('SELECT DoctorID FROM Doctors WHERE UserID = %s', user1.users_data["UserID"])
            temp = cursor.fetchone()
            user1.users_data["ID"] = temp[0]
            cursor.close()
            connection.close()
            messagebox.showinfo("Doctor Created", "Doctor Created Successfully")

            try:
                doctor_window.destroy()
                user_dashboard_window.destroy()
            except:
                pass

            display_doctor_dashboard()

    except pymysql.Error as err:
        print(f"Error: {err}")
        return False


def view_appointments():
    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            cursor.callproc("GetUpcomingVisits", (user1.users_data["ID"], user1.users_data["UserType"]))
            result = cursor.fetchall()
            cursor.close()
            connection.close()
    except pymysql.Error as err:
        print(f"Error: {err}")

    appointments_info_window = tk.Tk()
    appointments_info_window.geometry("1200x700")
    appointments_info_window.title("Appointment Information")

    tree_frame = tk.Frame(appointments_info_window, padx=10, pady=10)
    tree_frame.pack()

    vsb = ttk.Scrollbar(tree_frame, orient="vertical")
    hsb = ttk.Scrollbar(tree_frame, orient="horizontal")

    tree = ttk.Treeview(tree_frame,
                        columns=("Column 1", "Column 2", "Column 3", "Column 4", "Column 5", "Column 6", "Column 7"),
                        show='headings')
    tree.heading("Column 1", text="AppointmentID")
    tree.heading("Column 2", text="Patient Name")
    tree.heading("Column 3", text="Patient D.O.B")
    tree.heading("Column 4", text="Patient Gender")
    tree.heading("Column 5", text="Doctor Name")
    tree.heading("Column 6", text="Appointment Date")
    tree.heading("Column 7", text="Reason")

    vsb.config(command=tree.yview)
    vsb.pack(side="right", fill="y")

    hsb.config(command=tree.xview)
    hsb.pack(side="bottom", fill="x")

    def schedule_appointment():
        def submit_form():
            appointment_specialization = entry_specialization.get()
            appointment_date = datetime.strptime(entry_date.get(), '%Y-%m-%d %H:%M:%S')
            appointment_reason = entry_reason.get()
            try:
                connection = connect_to_database()
                if connection:
                    cursor = connection.cursor()
                    cursor.callproc("CreateAppointment", (user1.users_data["ID"], None,
                                                          appointment_specialization, appointment_date,
                                                          appointment_reason))
                    connection.commit()
                    result = cursor.fetchone()
                    cursor.close()
                    connection.close()
                    if result:
                        messagebox.showerror("Error", "Appointment create failed")
                    else:
                        messagebox.showinfo("Success", "Appointment created successfully")
            except pymysql.Error as err:
                print(f"Error: {err}")
                return err

        # Create the main window
        root = tk.Tk()
        root.title("Appointment Scheduler")

        # Create labels and entry widgets for Appointment Date, Reason, and Specialization
        label_specialization = ttk.Label(root, text="Specialization:")
        label_specialization.grid(row=0, column=0, padx=10, pady=10)

        entry_specialization = ttk.Entry(root)
        entry_specialization.grid(row=0, column=1, padx=10, pady=10)

        label_date = ttk.Label(root, text="Appointment Date:")
        label_date.grid(row=1, column=0, padx=10, pady=10)

        entry_date = ttk.Entry(root)
        entry_date.grid(row=1, column=1, padx=10, pady=10)

        label_reason = ttk.Label(root, text="Reason:")
        label_reason.grid(row=2, column=0, padx=10, pady=10)

        entry_reason = ttk.Entry(root)
        entry_reason.grid(row=2, column=1, padx=10, pady=10)

        # Create a submit button
        submit_button = ttk.Button(root, text="Submit", command=submit_form)
        submit_button.grid(row=3, column=0, columnspan=2, pady=20)

        # Start the main event loop
        root.mainloop()

    def reschedule_appointment():
        if not tree.selection():
            messagebox.showerror("Error", "Please select an appointment to cancel")
            return
        else:
            messagebox.askyesno("Confirmation", "Are you sure you want to cancel this appointment?")

        def submit_form():
            selected_row = tree.selection()
            if selected_row:
                apt_id = tree.item(selected_row[0])['values'][0]

            appointment_specialization = entry_specialization.get()
            appointment_date = datetime.strptime(entry_date.get(), '%Y-%m-%d %H:%M:%S')
            appointment_reason = entry_reason.get()
            try:
                connection = connect_to_database()
                if connection:
                    cursor = connection.cursor()
                    cursor.callproc("UpdateAppointment", (apt_id, user1.users_data["ID"], None,
                                                          appointment_specialization, appointment_date,
                                                          appointment_reason))
                    connection.commit()
                    result = cursor.fetchone()
                    cursor.close()
                    connection.close()
                    if result:
                        messagebox.showerror("Error", "Appointment update failed")
                    else:
                        messagebox.showinfo("Success", "Appointment update successfully")
            except pymysql.Error as err:
                print(f"Error: {err}")
                return err

        # Create the main window
        root = tk.Tk()
        root.title("Appointment Scheduler")

        # Create labels and entry widgets for Appointment Date, Reason, and Specialization
        label_specialization = ttk.Label(root, text="Specialization:")
        label_specialization.grid(row=0, column=0, padx=10, pady=10)

        entry_specialization = ttk.Entry(root)
        entry_specialization.grid(row=0, column=1, padx=10, pady=10)

        label_date = ttk.Label(root, text="Appointment Date:")
        label_date.grid(row=1, column=0, padx=10, pady=10)

        entry_date = ttk.Entry(root)
        entry_date.grid(row=1, column=1, padx=10, pady=10)

        label_reason = ttk.Label(root, text="Reason:")
        label_reason.grid(row=2, column=0, padx=10, pady=10)

        entry_reason = ttk.Entry(root)
        entry_reason.grid(row=2, column=1, padx=10, pady=10)

        # Create a submit button
        submit_button = ttk.Button(root, text="Submit", command=submit_form)
        submit_button.grid(row=3, column=0, columnspan=2, pady=20)

        # Start the main event loop
        root.mainloop()

    def cancel_appointment():
        if not tree.selection():
            messagebox.showerror("Error", "Please select an appointment to cancel")
            return
        else:
            messagebox.askyesno("Confirmation", "Are you sure you want to cancel this appointment?")
        selected_row = tree.selection()
        if selected_row:
            apt_id = tree.item(selected_row[0])['values'][0]
            result_status = delete_appointment_from_db(apt_id)
            if result_status:
                messagebox.showinfo("Success", "Appointment deleted successfully")
                tree.delete(selected_row[0])
            else:
                messagebox.showerror("Error", "Appointment deleted failed")

    for row in result:
        tree.insert("", "end", values=(row[0], row[1], row[2], row[3], row[4], row[5], row[6]))

    # for col in tree['columns']:
    #    tree.column(col, width=100)
    tree.pack(expand=True, fill="both")

    appointment_btn_frame = tk.Frame(appointments_info_window, padx=10, pady=10)
    appointment_btn_frame.pack()
    if user1.users_data["UserType"] == "Patient":
        schedule_appointment_button = tk.Button(appointment_btn_frame, text="Schedule Appointment",
                                                command=schedule_appointment)
        schedule_appointment_button.pack()

        reschedule_appointment_button = tk.Button(appointment_btn_frame, text="Reschedule Appointment",
                                                  command=reschedule_appointment)
        reschedule_appointment_button.pack()

    delete_button = tk.Button(appointment_btn_frame, text="Cancel Appointment", command=cancel_appointment)
    delete_button.pack()


def delete_appointment_from_db(appointment_id):
    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            stmt = f"DELETE FROM Appointments WHERE AppointmentID = {appointment_id}"
            cursor.execute(stmt)
            connection.commit()
            cursor.close()
            connection.close()
            return True
    except pymysql.Error as err:
        print(f"Error: {err}")
        return err


def view_billing(record_id):
    def get_total_billing():
        try:
            connection = connect_to_database()
            if connection:
                cursor = connection.cursor()
                cursor.execute(f"SELECT * FROM Billing WHERE RecordID = {record_id}")
                result_data = cursor.fetchall()
                cursor.close()
                connection.close()
                return result_data
        except pymysql.Error as err:
            print(f"Error: {err}")

    def get_itemized_bill():
        try:
            connection = connect_to_database()
            if connection:
                cursor = connection.cursor()
                cursor.callproc("GetItemizedBill", [record_id])
                result_data = cursor.fetchall()
                cursor.close()
                connection.close()
                return result_data
        except pymysql.Error as err:
            print(f"Error: {err}")

    def make_payment(billing_id):
        try:
            connection = connect_to_database()
            if connection:
                cursor = connection.cursor()
                cursor.callproc("UpdateBillingPaymentStatus", [billing_id, 'Paid'])
                connection.commit()  # Commit the changes to the database
                cursor.close()
                connection.close()
                print("Payment status updated successfully!")
        except pymysql.Error as err:
            print(f"Error: {err}")

    total_billing_data = get_total_billing()
    print(total_billing_data)
    root = tk.Tk()
    root.title("Billing Information")

    total_frame = tk.Frame(root)
    total_frame.pack(side=tk.TOP, padx=10, pady=10)
    # Create a Treeview widget
    tree = ttk.Treeview(total_frame, columns=("BillID", "RecordID", "Amount", "BillDate", "PaymentStatus"))

    # Define column headings
    tree.heading("BillID", text="Bill ID")
    tree.heading("RecordID", text="Record ID")
    tree.heading("Amount", text="Amount")
    tree.heading("BillDate", text="Bill Date")
    tree.heading("PaymentStatus", text="Payment Status")

    # Insert data into the Treeview
    for billing_record in total_billing_data:
        tree.insert("", "end", values=(
            billing_record[0], billing_record[1], billing_record[2], billing_record[3], billing_record[4]))

    # Pack the Treeview
    tree.pack(expand=True, fill="both")

    itemized_billing_data = get_itemized_bill()
    print(itemized_billing_data)
    itemized_frame = tk.Frame(root)
    itemized_frame.pack(side=tk.BOTTOM, padx=10, pady=10)

    # Create a Treeview widget for itemized billing data
    itemized_tree = ttk.Treeview(itemized_frame, columns=("Item", "Cost"))
    itemized_tree.heading("Item", text="Item")
    itemized_tree.heading("Cost", text="Cost")

    for item in itemized_billing_data:
        itemized_tree.insert("", "end", values=(
            item[0], item[1]))

    itemized_tree.pack(expand=True, fill="both")

    make_payment_button = tk.Button(root, text="Make Payment",
                                    command=lambda: make_payment(tree.item(tree.get_children()[0])['values'][0]))
    make_payment_button.pack(side=tk.BOTTOM, padx=10, pady=10)
    # Run the Tkinter main loop
    root.mainloop()


def get_patient_history(patient_id):
    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            cursor.callproc("GetMedicalRecords", [patient_id])
            result = cursor.fetchall()
            cursor.close()
            connection.close()

            # patient history window
            patient_history_window = tk.Tk()
            patient_history_window.geometry("1200x700")
            patient_history_window.title("Patient History")

            tree_frame = tk.Frame(patient_history_window, padx=10, pady=10)
            tree_frame.pack()

            vsb = ttk.Scrollbar(tree_frame, orient="vertical")
            hsb = ttk.Scrollbar(tree_frame, orient="horizontal")

            tree = ttk.Treeview(tree_frame,
                                columns=(
                                    "Column 1", "Column 2", "Column 3", "Column 4", "Column 5", "Column 6", "Column 7"),
                                show='headings')
            tree.heading("Column 1", text="RecordID")
            tree.heading("Column 2", text="DoctorID")
            tree.heading("Column 3", text="Doctor Name")
            tree.heading("Column 4", text="PatientID")
            tree.heading("Column 5", text="Patient Name")
            tree.heading("Column 6", text="Record Date")
            tree.heading("Column 7", text="Diagnosis")

            vsb.config(command=tree.yview)
            vsb.pack(side="right", fill="y")

            hsb.config(command=tree.xview)
            hsb.pack(side="bottom", fill="x")

            for row in result:
                tree.insert("", "end", values=(row[0], row[1], row[2], row[3], row[4], row[5], row[6]))

            tree.pack(expand=True, fill="both")

            if user1.users_data["UserType"] == "Patient":
                # Button to view billing
                view_billing_button = tk.Button(patient_history_window, text="View Billing",
                                                command=lambda: view_billing(
                                                    tree.item(tree.selection()[0])['values'][0]))
                view_billing_button.pack()

            patient_history_window.mainloop()

    except pymysql.Error as err:
        print(f"Error: {err}")


def create_medical_records():
    def get_doctors_patient_list():
        try:
            connection = connect_to_database()
            if connection:
                cursor = connection.cursor()
                current_doctor_id = user1.users_data["ID"]
                stmt = (
                    f"SELECT PatientID, CONCAT(FirstName, ' ', LastName) AS PatientName,ContactNumber FROM Patients WHERE PatientID IN (SELECT PatientID FROM Appointments WHERE DoctorID = {current_doctor_id})")
                cursor.execute(stmt)
                result_data = cursor.fetchall()
                cursor.close()
                connection.close()
                return result_data
        except pymysql.Error as err:
            print(f"Error: {err}")

    medical_records_window = tk.Tk()
    medical_records_window.geometry("1200x700")
    medical_records_window.title("Medical Records")

    def get_curr_patient_history():
        selected_row = tree.selection()
        patient_id = tree.item(selected_row[0])['values'][0]
        get_patient_history(patient_id)

    def create_diagnosis():
        def save_diagnosis():
            patient_id = tree.item(selected_row[0])['values'][0]
            diagnosis_text = diagnosis_entry.get()
            procedure_text = procedure_entry.get()
            medicine_text = medicine_entry.get()
            try:
                connection = connect_to_database()
                if connection:
                    cursor = connection.cursor()
                    current_datetime_str = datetime.now().strftime('%Y-%m-%d')
                    cursor.callproc("CreateMedicalRecord",
                                    (patient_id, user1.users_data["ID"], current_datetime_str, diagnosis_text))
                    connection.commit()
                    result = cursor.fetchall()
                    RecordID = result[0][0]

                    procedures = [procedure.strip() for procedure in procedure_text.split(",")]
                    medicines = [medicine.strip() for medicine in medicine_text.split(",")]
                    print(RecordID)
                    for procedure in procedures:
                        print(procedure)
                        cursor.callproc("AddProceduresAndMedicine", (RecordID, procedure))
                        connection.commit()
                    for medicine in medicines:
                        print(medicine)
                        cursor.callproc("AddProceduresAndMedicine", (RecordID, medicine))
                        connection.commit()

                    cursor = connection.cursor()
                    cursor.callproc("CreateBill", (RecordID, 0, 'Pending'))
                    connection.commit()

                    cursor.close()
                    connection.close()
                    if result[0]:
                        # Handle the result as needed
                        print("Medical record created successfully.")
                    else:
                        # Handle the case when the result is not as expected
                        print("Error: Failed to create medical record.")

            except pymysql.Error as err:
                print(f"Error: {err}")

        selected_row = tree.selection()
        if selected_row:
            apt_id = tree.item(selected_row[0])['values'][0]
            diagnosis_window = tk.Tk()
            diagnosis_window.geometry("800x800")
            diagnosis_window.title("Enter Patient Diagnosis")
            diagnosis_label = tk.Label(diagnosis_window, text="Diagnosis:")
            diagnosis_label.pack(pady=5)
            diagnosis_entry = tk.Entry(diagnosis_window, width=100)
            diagnosis_entry.pack(pady=5)
            procedure_label = tk.Label(diagnosis_window, text="List of Procedures(*,):")
            procedure_label.pack(pady=5)
            procedure_entry = tk.Entry(diagnosis_window, width=100)
            procedure_entry.pack(pady=5)
            medicine_label = tk.Label(diagnosis_window, text="List of Medicines(*,):")
            medicine_label.pack(pady=5)
            medicine_entry = tk.Entry(diagnosis_window, width=100)
            medicine_entry.pack(pady=5)

            save_button = tk.Button(diagnosis_window, text="Save", command=save_diagnosis)
            save_button.pack(pady=10)

    # create a treeview with dual scrollbars
    tree_frame = tk.Frame(medical_records_window, padx=10, pady=10)
    tree_frame.pack()

    tree = ttk.Treeview(tree_frame, columns=("Column 1", "Column 2", "Column 3"), show='headings')
    tree.heading("Column 1", text="PatientID")
    tree.heading("Column 2", text="Patient Name")
    tree.heading("Column 3", text="Contact Number")
    result = get_doctors_patient_list()
    for row in result:
        tree.insert("", "end", values=(row[0], row[1], row[2]))

    tree.pack(expand=True, fill="both")

    appointment_btn_frame = tk.Frame(medical_records_window, padx=10, pady=10)
    appointment_btn_frame.pack()

    create_record_button = ttk.Button(appointment_btn_frame, text="Create Medical Record", command=create_diagnosis)
    create_record_button.pack()

    view_pt_history_button = ttk.Button(appointment_btn_frame, text="View Patient History",
                                        command=get_curr_patient_history)
    view_pt_history_button.pack()


def prescribed_medicine():
    def get_patient_prescribed_medicines(user_id):
        try:
            connection = connect_to_database()
            if connection:
                cursor = connection.cursor()

                # Call the stored procedure
                cursor.callproc("GetPatientPrescribedMedicines", [user_id])

                # Fetch the results
                result_data = cursor.fetchall()

                cursor.close()
                connection.close()

                return result_data
        except pymysql.Error as err:
            print(f"Error: {err}")

    window = tk.Toplevel()
    window.title("Prescribed Medicines")

    tree_frame = tk.Frame(window, padx=10, pady=10)
    tree_frame.pack()

    vsb = ttk.Scrollbar(tree_frame, orient="vertical")
    hsb = ttk.Scrollbar(tree_frame, orient="horizontal")

    # Create a Treeview widget
    tree = ttk.Treeview(tree_frame, columns=("MedicineID",
                                             "MedicineName",
                                             "Manufacturer",
                                             "ExpiryDate",
                                             "DosageForm",
                                             "ActiveIngredient",
                                             "Price",
                                             "StorageConditions"))
    tree.heading("MedicineID", text="Medicine ID")
    tree.heading("MedicineName", text="Medicine Name")
    tree.heading("Manufacturer", text="Manufacturer")
    tree.heading("ExpiryDate", text="Expiry Date")
    tree.heading("DosageForm", text="Dosage Form")
    tree.heading("ActiveIngredient", text="Active Ingredient")
    tree.heading("Price", text="Price")
    tree.heading("StorageConditions", text="StorageConditions")

    vsb.config(command=tree.yview)
    vsb.pack(side="right", fill="y")

    hsb.config(command=tree.xview)
    hsb.pack(side="bottom", fill="x")

    # Get prescribed medicines data
    prescribed_medicines_data = get_patient_prescribed_medicines(user1.users_data["ID"])

    # Insert data into the Treeview
    for index, medicine_record in enumerate(prescribed_medicines_data, start=1):
        tree.insert("", "end", values=(
            medicine_record[0], medicine_record[1], medicine_record[2], medicine_record[3], medicine_record[4],
            medicine_record[5], medicine_record[6], medicine_record[7]))

    # Pack the Treeview
    tree.pack(expand=True, fill="both")


def display_start_up():
    start_up = tk.Tk()
    start_up.title("NUMD")
    start_up.geometry("500x300")

    # Welcome label
    welcome_label = tk.Label(start_up, text="Welcome to NUMD", font=("Helvetica", 16))
    welcome_label.pack(pady=20)

    # Login button
    login_button = tk.Button(start_up, text="Login", command=lambda: display_login_window(start_up))
    login_button.pack(pady=10)

    # Sign Up button
    signup_button = tk.Button(start_up, text="Sign Up", command=lambda: display_signup_window())
    signup_button.pack(pady=10)

    # Run the main loop
    start_up.mainloop()


def display_login_window(start_up):
    # Create the login window
    login_window = tk.Tk()
    login_window.title("Login")

    # Create and configure the login window widgets
    username_label = tk.Label(login_window, text="Username:")
    username_label.grid(row=0, column=0, padx=10, pady=10, sticky="E")

    username_entry = tk.Entry(login_window)
    username_entry.grid(row=0, column=1, padx=10, pady=10)

    password_label = tk.Label(login_window, text="Password:")
    password_label.grid(row=1, column=0, padx=10, pady=10, sticky="E")

    password_entry = tk.Entry(login_window, show="*")
    password_entry.grid(row=1, column=1, padx=10, pady=10)

    login_button = tk.Button(login_window, text="Login",
                             command=lambda: login(start_up, login_window, username_entry.get(), password_entry.get()))
    login_button.grid(row=2, column=0, columnspan=2, pady=10)

    # Run the login window's main loop
    login_window.mainloop()


def display_signup_window():
    signup_window = tk.Tk()
    signup_window.title("Signup")

    # Form elements
    username_label = tk.Label(signup_window, text="Username:")
    username_label.pack(pady=5)

    username_entry = tk.Entry(signup_window)
    username_entry.pack(pady=5)

    password_label = tk.Label(signup_window, text="Password:")
    password_label.pack(pady=5)

    password_entry = tk.Entry(signup_window, show="*")  # Hide the entered characters
    password_entry.pack(pady=5)

    user_type_label = tk.Label(signup_window, text="User Type:")
    user_type_label.pack(pady=5)

    user_types = ["Patient", "Doctor"]
    user_type_var = tk.StringVar()
    user_type_var.set(user_types[0])  # Set the default value
    user_type_dropdown = ttk.Combobox(signup_window, textvariable=user_type_var, values=user_types, state="readonly")
    user_type_dropdown.pack(pady=10)

    # Submit button
    submit_button = tk.Button(signup_window, text="Submit",
                              command=lambda: signup(signup_window, username_entry.get(), password_entry.get(),
                                                     user_type_dropdown.get()))
    submit_button.pack(pady=10)
    # Run the login window's main loop
    signup_window.mainloop()


def display_user_dashboard():
    # Create a new window or frame for the dashboard view
    user_dashboard_window = tk.Tk()
    user_dashboard_window.title("Select User Type")

    # Button for signing out
    sign_out_button = tk.Button(user_dashboard_window, text="Sign Out",
                                command=lambda: sign_out(user_dashboard_window))
    sign_out_button.pack(pady=10)

    if user1.users_data["UserType"] == "Patient":
        # Button for creating a patient
        create_patient_button = tk.Button(user_dashboard_window, text="Create Patient",
                                          command=lambda: display_create_patient(user_dashboard_window))
        create_patient_button.pack(pady=10)
    elif user1.users_data["UserType"] == "Doctor":
        # Button for creating a doctor
        create_doctor_button = tk.Button(user_dashboard_window, text="Create Doctor",
                                         command=lambda: display_create_doctor(user_dashboard_window))
        create_doctor_button.pack(pady=10)

    user_dashboard_window.mainloop()


def display_create_patient(user_dashboard_window):
    # Placeholder function for creating a patient
    # You can replace this with the actual logic to create a patient
    print("Creating a new patient")
    # Create and configure the login window widgets
    patient_window = tk.Tk()
    patient_window.geometry("800x800")
    patient_window.title("Enter Patient details")

    first_name_label = tk.Label(patient_window, text="First Name:")
    first_name_label.grid(row=0, column=0, padx=10, pady=10, sticky="E")

    first_name_entry = tk.Entry(patient_window)
    first_name_entry.grid(row=0, column=1, padx=10, pady=10)

    last_name_label = tk.Label(patient_window, text="Last Name:")
    last_name_label.grid(row=1, column=0, padx=10, pady=10, sticky="E")

    last_name_entry = tk.Entry(patient_window)
    last_name_entry.grid(row=1, column=1, padx=10, pady=10)

    date_of_birth_label = tk.Label(patient_window, text="Date of Birth(YYYY-MM-DD):")
    date_of_birth_label.grid(row=2, column=0, padx=10, pady=10, sticky="E")

    date_of_birth_entry = tk.Entry(patient_window)
    date_of_birth_entry.grid(row=2, column=1, padx=10, pady=10)

    phone_number_label = tk.Label(patient_window, text="Phone Number:")
    phone_number_label.grid(row=3, column=0, padx=10, pady=10, sticky="E")

    phone_number_entry = tk.Entry(patient_window)
    phone_number_entry.grid(row=3, column=1, padx=10, pady=10)

    email_label = tk.Label(patient_window, text="Email:")
    email_label.grid(row=4, column=0, padx=10, pady=10, sticky="E")

    email_entry = tk.Entry(patient_window)
    email_entry.grid(row=4, column=1, padx=10, pady=10)

    address_label = tk.Label(patient_window, text="Address:")
    address_label.grid(row=5, column=0, padx=10, pady=10, sticky="E")

    address_entry = tk.Entry(patient_window)
    address_entry.grid(row=5, column=1, padx=10, pady=10)

    gender_label = tk.Label(patient_window, text="Gender:")
    gender_label.grid(row=6, column=0, padx=10, pady=10, sticky="E")

    gender = ['Male', 'Female', 'Other']
    gender_value = tk.StringVar()
    gender_value.set(gender[0])  # Set the default value
    gender_value_dropdown = ttk.Combobox(patient_window, textvariable=gender_value, values=gender, state="readonly")
    gender_value_dropdown.grid(row=6, column=1, padx=10, pady=10)

    submit_button = tk.Button(patient_window, text="Submit",
                              command=lambda: create_patient(user_dashboard_window,
                                                             patient_window,
                                                             first_name_entry.get(),
                                                             last_name_entry.get(),
                                                             date_of_birth_entry.get(),
                                                             gender_value_dropdown.get(),
                                                             phone_number_entry.get(),
                                                             email_entry.get(),
                                                             address_entry.get()))
    submit_button.grid(row=7, column=0, columnspan=2, pady=10)


def get_doctor_specialization():
    try:
        connection = connect_to_database()
        if connection:
            cursor = connection.cursor()
            stmt = "SELECT SpecializationName from Specializations"
            cursor.execute(stmt)
            result = cursor.fetchall()
            cursor.close()
            connection.close()
            return result
    except pymysql.Error as err:
        print(f"Error: {err}")
        return None


def display_create_doctor(user_dashboard_window):
    # Placeholder function for creating a patient
    # You can replace this with the actual logic to create a patient
    print("Creating a new doctor")
    # Create and configure the login window widgets
    doctor_window = tk.Tk()
    doctor_window.geometry("800x800")
    doctor_window.title("Enter Doctor details")

    first_name_label = tk.Label(doctor_window, text="First Name:")
    first_name_label.grid(row=0, column=0, padx=10, pady=10, sticky="E")

    first_name_entry = tk.Entry(doctor_window)
    first_name_entry.grid(row=0, column=1, padx=10, pady=10)

    last_name_label = tk.Label(doctor_window, text="Last Name:")
    last_name_label.grid(row=1, column=0, padx=10, pady=10, sticky="E")

    last_name_entry = tk.Entry(doctor_window)
    last_name_entry.grid(row=1, column=1, padx=10, pady=10)

    phone_number_label = tk.Label(doctor_window, text="Phone Number:")
    phone_number_label.grid(row=3, column=0, padx=10, pady=10, sticky="E")

    phone_number_entry = tk.Entry(doctor_window)
    phone_number_entry.grid(row=3, column=1, padx=10, pady=10)

    email_label = tk.Label(doctor_window, text="Email:")
    email_label.grid(row=4, column=0, padx=10, pady=10, sticky="E")

    email_entry = tk.Entry(doctor_window)
    email_entry.grid(row=4, column=1, padx=10, pady=10)

    address_label = tk.Label(doctor_window, text="Address:")
    address_label.grid(row=5, column=0, padx=10, pady=10, sticky="E")

    address_entry = tk.Entry(doctor_window)
    address_entry.grid(row=5, column=1, padx=10, pady=10)

    specialization_label = tk.Label(doctor_window, text="Specialization:")
    specialization_label.grid(row=6, column=0, padx=10, pady=10, sticky="E")

    specialization_choices = get_doctor_specialization()
    specialization = []
    for i in specialization_choices:
        specialization.append(i[0])

    specialization_value = tk.StringVar()
    specialization_value.set(specialization[0])  # Set the default value
    specialization_value_dropdown = ttk.Combobox(doctor_window, textvariable=specialization_value,
                                                 values=specialization,
                                                 state="readonly")
    specialization_value_dropdown.grid(row=6, column=1, padx=10, pady=10)

    submit_button = tk.Button(doctor_window, text="Submit",
                              command=lambda: create_doctor(user_dashboard_window,
                                                            doctor_window,
                                                            first_name_entry.get(),
                                                            last_name_entry.get(),
                                                            specialization_value_dropdown.get(),
                                                            phone_number_entry.get(),
                                                            email_entry.get(),
                                                            address_entry.get()))
    submit_button.grid(row=7, column=0, columnspan=2, pady=10)


def display_patient_dashboard():
    # Create a new window or frame for the dashboard view
    patient_dashboard_window = tk.Tk()
    patient_dashboard_window.title("NUMD Patient Dashboard")
    patient_dashboard_window.geometry("800x700")

    # Button for signing out
    sign_out_button = tk.Button(patient_dashboard_window, text="Sign Out",
                                command=lambda: sign_out(patient_dashboard_window))
    sign_out_button.pack(pady=10)

    # Add elements to the dashboard view
    # Example: Label, buttons, etc.
    label = tk.Label(patient_dashboard_window, text="Welcome to the NUMD Dashboard!")
    label.pack()

    user_info_frame = tk.Frame(patient_dashboard_window, padx=10, pady=10)
    user_info_frame.pack()

    welcome_label = tk.Label(user_info_frame, text=f"Welcome, {user1.users_data['Username']}!")
    welcome_label.pack()

    user_id_label = tk.Label(user_info_frame, text=f"UserID: {user1.users_data['UserID']}")
    user_id_label.pack()

    username_label = tk.Label(user_info_frame, text=f"Username: {user1.users_data['Username']}")
    username_label.pack()

    user_type_label = tk.Label(user_info_frame, text=f"UserType: {user1.users_data['UserType']}")
    user_type_label.pack()

    patient_id_label = tk.Label(user_info_frame, text=f"PatientID: {user1.users_data['ID']}")
    patient_id_label.pack()

    # Section for appointments
    appointments_frame = tk.Frame(patient_dashboard_window, padx=10, pady=10)
    appointments_frame.pack()

    appointments_label = tk.Label(appointments_frame, text="Appointments")
    appointments_label.pack()

    # Buttons for appointments
    view_appointments_button = tk.Button(appointments_frame, text="View Appointments",
                                         command=view_appointments)
    view_appointments_button.pack()

    # Section for Medical Report
    medical_report_frame = tk.Frame(patient_dashboard_window, padx=10, pady=10)
    medical_report_frame.pack()

    medical_report_label = tk.Label(medical_report_frame, text="Medical Report")
    medical_report_label.pack()

    # Buttons for Medical Report
    view_medical_report_button = tk.Button(medical_report_frame, text="View Medical Report",
                                           command=lambda: get_patient_history(user1.users_data["ID"]))
    view_medical_report_button.pack()

    prescribed_medicine_button = tk.Button(medical_report_frame, text="Prescribed Medicine",
                                           command=prescribed_medicine)
    prescribed_medicine_button.pack()

    patient_dashboard_window.mainloop()


def display_doctor_dashboard():
    # Create a new window or frame for the dashboard view
    doctor_dashboard_window = tk.Tk()
    doctor_dashboard_window.title("NUMD Doctor Dashboard")
    doctor_dashboard_window.geometry("800x700")

    # Button for signing out
    sign_out_button = tk.Button(doctor_dashboard_window, text="Sign Out",
                                command=lambda: sign_out(doctor_dashboard_window))
    sign_out_button.pack(pady=10)

    label = tk.Label(doctor_dashboard_window, text="Welcome to the NUMD Doctor Dashboard!")
    label.pack()

    # Button for viewing appointments
    view_appointments_button = tk.Button(doctor_dashboard_window, text="View Appointments",
                                         command=view_appointments)
    view_appointments_button.pack(pady=10)

    # Button for creating medical records
    create_medical_records_button = tk.Button(doctor_dashboard_window, text="View Patient Records",
                                              command=create_medical_records)
    create_medical_records_button.pack(pady=10)

    doctor_dashboard_window.mainloop()


user1 = Users()


def main():
    display_start_up()


if __name__ == "__main__":
    main()
