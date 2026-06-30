import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_document.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_note.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_site.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/document_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/fuel_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/payment_terms.dart';

/// Extension methods to convert database rows and companions to/from domain entities.
extension CustomerRowMapper on CustomerRow {
  Customer toDomain() {
    return Customer(
      id: id,
      customerCode: customerCode,
      name: name,
      displayName: displayName,
      tradeName: tradeName,
      legalBusinessName: legalBusinessName,
      type: CustomerType.values.firstWhere(
        (e) => e.name.toLowerCase() == customerType.toLowerCase(),
        orElse: () => CustomerType.company,
      ),
      isActive: isActive,
      gstin: gstin,
      pan: pan,
      state: state,
      placeOfSupply: placeOfSupply,
      gstRegistrationType: gstRegistrationType,
      tan: tan,
      billingAddressLine1: billingAddressLine1,
      billingAddressLine2: billingAddressLine2,
      billingArea: billingArea,
      billingCity: billingCity,
      billingState: billingState,
      billingPincode: billingPincode,
      billingCountry: billingCountry,
      paymentTerms: paymentTerms == null
          ? null
          : PaymentTerms.values.firstWhere(
              (e) => e.name.toLowerCase() == paymentTerms!.toLowerCase(),
              orElse: () => PaymentTerms.advance,
            ),
      creditLimit: creditLimit,
      creditDays: creditDays,
      securityDeposit: securityDeposit,
      fuelType: fuelType == null
          ? null
          : FuelType.values.firstWhere(
              (e) => e.name.toLowerCase() == fuelType!.toLowerCase(),
              orElse: () => FuelType.diesel,
            ),
      defaultGstRate: defaultGstRate,
      defaultPrice: defaultPrice,
      poNumber: poNumber,
      poDate: poDate,
      poValidTill: poValidTill,
      poValue: poValue,
      poRemainingBalance: poRemainingBalance,
      invoicePrefix: invoicePrefix,
      emailInvoice: emailInvoice,
      whatsappInvoice: whatsappInvoice,
      requirePo: requirePo,
      requireDc: requireDc,
      requireSignature: requireSignature,
      gstApplicable: gstApplicable,
      eInvoiceRequired: eInvoiceRequired,
      eWayBillRequired: eWayBillRequired,
      openingBalance: openingBalance,
      currentBalance: currentBalance,
      lastPaymentDate: lastPaymentDate,
      lastInvoiceDate: lastInvoiceDate,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      tenantId: tenantId,
    );
  }
}

extension CustomerMapper on Customer {
  CustomersCompanion toCompanion() {
    return CustomersCompanion(
      id: Value(id),
      customerCode: Value(customerCode),
      name: Value(name),
      displayName: Value(displayName),
      tradeName: Value(tradeName),
      legalBusinessName: Value(legalBusinessName),
      customerType: Value(type.name.toUpperCase()),
      isActive: Value(isActive),
      gstin: Value(gstin),
      pan: Value(pan),
      state: Value(state),
      placeOfSupply: Value(placeOfSupply),
      gstRegistrationType: Value(gstRegistrationType),
      tan: Value(tan),
      billingAddressLine1: Value(billingAddressLine1),
      billingAddressLine2: Value(billingAddressLine2),
      billingArea: Value(billingArea),
      billingCity: Value(billingCity),
      billingState: Value(billingState),
      billingPincode: Value(billingPincode),
      billingCountry: Value(billingCountry),
      paymentTerms: Value(paymentTerms?.name.toUpperCase()),
      creditLimit: Value(creditLimit),
      creditDays: Value(creditDays),
      securityDeposit: Value(securityDeposit),
      fuelType: Value(fuelType?.name.toUpperCase()),
      defaultGstRate: Value(defaultGstRate),
      defaultPrice: Value(defaultPrice),
      poNumber: Value(poNumber),
      poDate: Value(poDate),
      poValidTill: Value(poValidTill),
      poValue: Value(poValue),
      poRemainingBalance: Value(poRemainingBalance),
      invoicePrefix: Value(invoicePrefix),
      emailInvoice: Value(emailInvoice),
      whatsappInvoice: Value(whatsappInvoice),
      requirePo: Value(requirePo),
      requireDc: Value(requireDc),
      requireSignature: Value(requireSignature),
      gstApplicable: Value(gstApplicable),
      eInvoiceRequired: Value(eInvoiceRequired),
      eWayBillRequired: Value(eWayBillRequired),
      openingBalance: Value(openingBalance),
      currentBalance: Value(currentBalance),
      lastPaymentDate: Value(lastPaymentDate),
      lastInvoiceDate: Value(lastInvoiceDate),
      notes: Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version),
      tenantId: Value(tenantId),
    );
  }
}

extension CustomerSiteRowMapper on CustomerSiteRow {
  CustomerSite toDomain() {
    return CustomerSite(
      id: id,
      customerId: customerId,
      name: name,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      stateCode: stateCode,
      pincode: pincode,
      country: country,
      latitude: latitude,
      longitude: longitude,
      contactPerson: contactPerson,
      contactNumber: contactNumber,
      isDefault: isDefault,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      tenantId: tenantId,
    );
  }
}

extension CustomerSiteMapper on CustomerSite {
  CustomerSitesCompanion toCompanion() {
    return CustomerSitesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      name: Value(name),
      addressLine1: Value(addressLine1),
      addressLine2: Value(addressLine2),
      city: Value(city),
      state: Value(state),
      stateCode: Value(stateCode),
      pincode: Value(pincode),
      country: Value(country),
      latitude: Value(latitude),
      longitude: Value(longitude),
      contactPerson: Value(contactPerson),
      contactNumber: Value(contactNumber),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version),
      tenantId: Value(tenantId),
    );
  }
}

extension CustomerContactRowMapper on CustomerContactRow {
  CustomerContact toDomain() {
    return CustomerContact(
      id: id,
      customerId: customerId,
      name: name,
      designation: designation,
      phone: phone,
      email: email,
      whatsapp: whatsapp,
      isPrimary: isPrimary,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      tenantId: tenantId,
    );
  }
}

extension CustomerContactMapper on CustomerContact {
  CustomerContactsCompanion toCompanion() {
    return CustomerContactsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      name: Value(name),
      designation: Value(designation),
      phone: Value(phone),
      email: Value(email),
      whatsapp: Value(whatsapp),
      isPrimary: Value(isPrimary),
      isActive: Value(isActive),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version),
      tenantId: Value(tenantId),
    );
  }
}

extension CustomerDocumentRowMapper on CustomerDocumentRow {
  CustomerDocument toDomain() {
    return CustomerDocument(
      id: id,
      customerId: customerId,
      documentType: DocumentType.values.firstWhere(
        (e) => e.name.toLowerCase() == documentType.toLowerCase(),
        orElse: () => DocumentType.other,
      ),
      fileUrl: fileUrl,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      tenantId: tenantId,
    );
  }
}

extension CustomerDocumentMapper on CustomerDocument {
  CustomerDocumentsCompanion toCompanion() {
    return CustomerDocumentsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      documentType: Value(documentType.name.toUpperCase()),
      fileUrl: Value(fileUrl),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      tenantId: Value(tenantId),
    );
  }
}

extension CustomerNoteRowMapper on CustomerNoteRow {
  CustomerNote toDomain() {
    return CustomerNote(
      id: id,
      customerId: customerId,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      tenantId: tenantId,
    );
  }
}

extension CustomerNoteMapper on CustomerNote {
  CustomerNotesCompanion toCompanion() {
    return CustomerNotesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      notes: Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      tenantId: Value(tenantId),
    );
  }
}
