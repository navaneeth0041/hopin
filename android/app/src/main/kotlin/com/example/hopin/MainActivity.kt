package com.example.hopin

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.telephony.SmsManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hopin/sos"
    private val PERMISSION_REQUEST_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val number = call.argument<String>("number")
                    val message = call.argument<String>("message")
                    
                    if (number != null && message != null) {
                        if (checkSmsPermission()) {
                            sendSMS(number, message)
                            result.success("SMS sent to $number")
                        } else {
                            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                        }
                    } else {
                        result.error("UNAVAILABLE", "SMS parameters missing", null)
                    }
                }
                
                "sendBulkSMS" -> {
                    val contacts = call.argument<List<Map<String, String>>>("contacts")
                    val message = call.argument<String>("message")
                    
                    if (contacts != null && message != null) {
                        if (checkSmsPermission()) {
                            sendBulkSMS(contacts, message)
                            result.success("Bulk SMS sent to ${contacts.size} contacts")
                        } else {
                            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                        }
                    } else {
                        result.error("UNAVAILABLE", "Bulk SMS parameters missing", null)
                    }
                }
                
                "makeCall" -> {
                    val number = call.argument<String>("number")
                    
                    if (number != null) {
                        if (checkCallPermission()) {
                            makeCall(number)
                            result.success("Calling $number")
                        } else {
                            result.error("PERMISSION_DENIED", "Call permission not granted", null)
                        }
                    } else {
                        result.error("UNAVAILABLE", "Call parameters missing", null)
                    }
                }
                
                "checkPermissions" -> {
                    val hasPermissions = checkSmsPermission() && checkCallPermission()
                    result.success(hasPermissions)
                }
                
                "requestPermissions" -> {
                    requestPermissions()
                    result.success(null)
                }
                
                else -> result.notImplemented()
            }
        }
    }

    private fun checkSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.SEND_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun checkCallPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermissions() {
        val permissions = arrayOf(
            Manifest.permission.SEND_SMS,
            Manifest.permission.CALL_PHONE
        )
        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }

    private fun sendSMS(number: String, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            
            // Split message if it's too long (SMS limit is 160 characters)
            val parts = smsManager.divideMessage(message)
            
            if (parts.size > 1) {
                smsManager.sendMultipartTextMessage(
                    number,
                    null,
                    parts,
                    null,
                    null
                )
            } else {
                smsManager.sendTextMessage(number, null, message, null, null)
            }
            
            Log.d("HopIn_SOS", "SMS sent successfully to $number")
        } catch (e: Exception) {
            Log.e("HopIn_SOS", "Failed to send SMS to $number: ${e.message}", e)
        }
    }

    private fun sendBulkSMS(contacts: List<Map<String, String>>, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            val parts = smsManager.divideMessage(message)
            
            for (contact in contacts) {
                val number = contact["phoneNumber"]
                if (number != null) {
                    try {
                        if (parts.size > 1) {
                            smsManager.sendMultipartTextMessage(
                                number,
                                null,
                                parts,
                                null,
                                null
                            )
                        } else {
                            smsManager.sendTextMessage(number, null, message, null, null)
                        }
                        Log.d("HopIn_SOS", "Bulk SMS sent to $number")
                    } catch (e: Exception) {
                        Log.e("HopIn_SOS", "Failed to send SMS to $number: ${e.message}", e)
                    }
                }
            }
            Log.d("HopIn_SOS", "Bulk SMS operation completed for ${contacts.size} contacts")
        } catch (e: Exception) {
            Log.e("HopIn_SOS", "Bulk SMS operation failed: ${e.message}", e)
        }
    }

    private fun makeCall(number: String) {
        try {
            val intent = Intent(Intent.ACTION_CALL)
            intent.data = Uri.parse("tel:$number")
            startActivity(intent)
            Log.d("HopIn_SOS", "Calling $number")
        } catch (e: Exception) {
            Log.e("HopIn_SOS", "Failed to make call to $number: ${e.message}", e)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            Log.d("HopIn_SOS", "Permissions result: $allGranted")
        }
    }
}