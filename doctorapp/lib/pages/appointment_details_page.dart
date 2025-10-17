import 'package:doctorapp/model/patient_file_model.dart';
import 'package:doctorapp/model/prescription_pre_field_model.dart';
import 'package:doctorapp/pages/write_prescription_page.dart';
import 'package:doctorapp/service/patient_files_service.dart';
import '../helper/route_helper.dart';
import '../service/prescription_service.dart';
import '../widget/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/appointment_cancel_req_controller.dart';
import '../controller/appointment_controller.dart';
import '../controller/boked_time_slot_controller.dart';
import '../controller/prescription_controller.dart';
import '../controller/time_slots_controller.dart';
import '../helper/date_time_helper.dart';
import '../model/appointment_cancellation_model.dart';
import '../model/appointment_model.dart';
import '../model/booked_time_slot_mdel.dart';
import '../model/invoice_model.dart';
import '../model/prescription_model.dart';
import '../model/time_slots_model.dart';
import '../service/appointment_Service.dart';
import '../service/invoice_service.dart';
import '../utilities/api_content.dart';
import '../utilities/colors_constant.dart';
import '../widget/app_bar_widget.dart';
import '../widget/button_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/toast_message.dart';
import 'package:get/get.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String? appId;
  const AppointmentDetailsPage({super.key,this.appId});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  bool _isLoading=false;
  AppointmentModel? appointmentModel;
  List<PatientFileModel> patientFileMode=[];
  InvoiceModel? invoiceModel ;
  final AppointmentCancellationController _appointmentCancellationController=AppointmentCancellationController();
  final PrescriptionController _prescriptionController= Get.put(PrescriptionController());
  // final PatientFileController _patientFileController= Get.put(PatientFileController());

  String selectedAppointmentStatus="";
  final ScrollController _scrollController=ScrollController();
  TextEditingController textEditingController=TextEditingController();
  final TimeSlotsController _timeSlotsController = Get.put(TimeSlotsController());
  final BookedTimeSlotsController _bookedTimeSlotsController = Get.put(BookedTimeSlotsController());
  AppointmentController appointmentController = Get.find<AppointmentController>();
  String _selectedDate="";
  String _setTime="";
  @override
  void initState() {
    // TODO: implement initState
    getAndSetData();
    _appointmentCancellationController.getData(appointmentId: widget.appId??"-1");
    _prescriptionController.getData(appointmentId: widget.appId??"-1");


    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: IBottomNavBarWidget(
        title: "Add Prescription",
        onPressed: (){
          _openBottomSheet();
        },
      ),
      backgroundColor: ColorResources.bgColor,
      appBar: IAppBar.commonAppBar(title: "Appointment"),
      floatingActionButton:
      appointmentModel?.status=="Rejected"
       ||appointmentModel?.status=="Cancelled"
          ||appointmentModel?.status=="Visited"
          ||appointmentModel?.status=="Completed"
          ?null:
      _isLoading||appointmentModel==null?null:FloatingActionButton(
        backgroundColor: ColorResources.btnColor,
        onPressed: () {
          selectedAppointmentStatus=appointmentModel?.status??"";
          _openBottomSheetAppointmentStatus();
        },
        shape:  const CircleBorder(),
        child:  const Icon(Icons.edit,
          color: Colors.white,),
      ),
      body:_isLoading||appointmentModel==null?const ILoadingIndicatorWidget(): _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(5),
      children: [
        buildOpDetails(),
        const SizedBox(height: 10),
        Padding(padding:const EdgeInsets.only(bottom: 10),
        child:     _buildPrescriptionListBox(),
        ),
        Padding(padding:const EdgeInsets.only(bottom: 10),
          child:     _buildPatientFileListBox(),
        ),

        _buildPaymentCard(),
        const SizedBox(height: 10),
        _buildCancellationBox(),
        Obx(()
        {return  _appointmentCancellationController.dataList.isNotEmpty?_buildCancellationReqListBox():Container();
        }),

      ],
    );
  }

  void getAndSetData() async{
    setState(() {
      _isLoading=true;
    });
    final appointmentData=await AppointmentService.getDataById(appId: widget.appId);
    appointmentModel=appointmentData;
    final invoiceData=await InvoiceService.getDataByAppId(appId: widget.appId);
    invoiceModel=invoiceData;
    appointmentController.getData();
    final resPatientFile=await PatientFilesService.getData(appointmentModel?.patientId.toString()??"", "");
    if(resPatientFile!=null&&resPatientFile.isNotEmpty){
      patientFileMode=resPatientFile;
    }
    // _patientFileController.getData(appointmentModel?.patientId.toString()??"", "");
    if (mounted) {
      setState(() {
        _isLoading=false;
      });
    }

  }
  buildOpDetails() {
    return Card(
      color:  ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("Appointment #${widget.appId??"--"}",
                  style: const TextStyle(
                      color: ColorResources.secondaryFontColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                  ),),
                const SizedBox(width: 5),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child:  appointmentModel!.status ==
                            "Pending"
                            ? _statusIndicator(Colors.yellowAccent)
                            : appointmentModel!.status ==
                            "Rescheduled"
                            ? _statusIndicator(Colors.orangeAccent)
                            : appointmentModel!.status ==
                            "Rejected"
                            ? _statusIndicator(Colors.red)
                            : appointmentModel!.status ==
                            "Confirmed"
                            ? _statusIndicator(Colors.green)
                            : appointmentModel!.status ==
                            "Completed"
                            ? _statusIndicator(Colors.green)
                            : null),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                      child: Text(
                        appointmentModel!.status??"--",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
             Text("Dear ${appointmentModel!.pFName??"--"} ${appointmentModel!.pLName??"--"}",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600
              ),),
            const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                  appointmentModel!.type??"--",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                              ),
                  appointmentModel!.type=="Video Consultant"?
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(5.0)),
                      ),
                      onPressed:   appointmentModel?.status=="Rejected"
                          ||appointmentModel?.status=="Cancelled"
                          ||appointmentModel?.status=="Visited"
                          ||appointmentModel?.status=="Completed"
                          ?null:() {
                      //  print(appointmentModel?.meetingLink);
                        if(appointmentModel?.meetingLink!=null||appointmentModel?.meetingLink!=""){
                          launchUrl(Uri.parse(appointmentModel!.meetingLink!),
                          mode: LaunchMode.externalApplication
                          );
                        }

                        //   Get.toNamed(RouteHelper.getBookingDetailsPageRoute());
                      },
                      child:const  Center(
                          child: Text("Video Call",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              )))):Container()
                ],
              ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12
                        ),),
                      Card(
                          color:  ColorResources.cardBgColor,
                          elevation: .1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: ListTile(
                            title:   Text(DateTimeHelper.getDataFormat(
                                appointmentModel?.date ?? ""),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13
                                )
                            ),
                            trailing: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                color: Colors.black,
                                child:
                                const Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Icon(Icons.calendar_month,
                                    color: Colors.white,
                                  size: 15,),
                                )),
                          ))
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Time",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12
                        ),),
                      GestureDetector(
                        onTap: (){
                        },
                        child: Card(
                            color:  ColorResources.cardBgColor,
                            elevation: .1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),

                            child: ListTile(
                              title:  Text(DateTimeHelper.convertTo12HourFormat(
                                  appointmentModel?.timeSlot ?? ""),
                                style:const  TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13
                                ),),
                              trailing: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.black,
                                  child:
                                  const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(Icons.watch_later,
                                      size: 15,
                                      color: Colors.white,),
                                  )),
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
          ],

        ),
      ),
    );
  }
  Widget _statusIndicator(color) {
    return CircleAvatar(radius: 4, backgroundColor: color);
  }

  _buildPaymentCard() {
    return      GestureDetector(
      onTap: (){
        //download invoice
      },
      child: Card(
        color:  ColorResources.cardBgColor,
        elevation: .1,
        // elevation: .1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child:  ListTile(
          title: Text("Payment Status ${invoiceModel==null?"--":invoiceModel?.paymentId.toString()??"--"}",
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14
            ),),
          trailing:  Text(invoiceModel==null?"--":invoiceModel?.status??"--",
            style: const TextStyle(
                color: ColorResources.primaryColor,
                // fontWeight: FontWeight.w500,
                fontSize: 13
            ),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
             GestureDetector(
               onTap: (){
                 launchUrl(Uri.parse("${ApiContents.invoiceUrl}/${invoiceModel?.id}"));
               },
               child: const  Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                Text("Download Invoice",
                    style:  TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 14
                      ,
                    )),
                SizedBox(width: 5),
                Icon(Icons.download,
                    color: Colors.green,
                    size: 16)
                           ],
                         ),
             )

            ],
          ),
        ),
      ),
    );
  }


  _buildCancellationBox() {
    return  Card(
      color:  ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:  ListTile(
        onTap:  appointmentModel?.currentCancelReqStatus==null
            || appointmentModel?.currentCancelReqStatus=="Approved"?null:
            (){
                selectedAppointmentStatus="Cancelled";
                _openDialogBox();
               },
        trailing: const Icon(Icons.arrow_right,
        color: ColorResources.btnColor,),
         title:const  Text("Appointment Cancellation Request",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            appointmentModel?.currentCancelReqStatus==null?
            const Text("No cancellation request generated by user. you can reject this appointmet",
                style: TextStyle(
                    color: ColorResources.secondaryFontColor,
                    fontSize: 13
                )):
            appointmentModel?.currentCancelReqStatus==null?Container():
               Padding(
              padding: const EdgeInsets.only(top:3),
              child: Text( "Current Status - ${appointmentModel?.currentCancelReqStatus??"--"}",
                style:  const TextStyle(
                    color: ColorResources.secondaryFontColor,
                    fontSize: 13
                ),),
            ),
            appointmentModel?.currentCancelReqStatus==null|| appointmentModel?.currentCancelReqStatus=="Approved"?Container(): const Padding(
              padding: EdgeInsets.only(top:3.0),
              child: Text( "Click here to cancel this appointment.",
                style:  TextStyle(
                    color: ColorResources.secondaryFontColor,
                    fontSize: 13
                ),),
            ),

    appointmentModel?.currentCancelReqStatus=="Approved"?
    const Padding(
      padding: EdgeInsets.only(top:3.0),
      child: Text( "Appointment has been canceled, can't edit the status.",
        style:  TextStyle(
            color: ColorResources.secondaryFontColor,
            fontSize: 13
        ),),
    ):Container()
          ],
        ),
      ),
    );
  }


  _buildCancellationReqListBox() {
    return Card(
      color:  ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
        Obx(()
        {
          if (!_appointmentCancellationController.isError.value) { // if no any error
            if (_appointmentCancellationController.isLoading.value) {
              return const  ILoadingIndicatorWidget();
            } else {
                 return _appointmentCancellationController.dataList.isEmpty?Container():ListTile(
                   title:const  Text("Cancellation Request History" ,
                     style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.w500
                     ),),
                   subtitle: ListView.builder(
                       controller: _scrollController,
                     shrinkWrap: true,
                        itemCount:_appointmentCancellationController.dataList.length ,
                        itemBuilder: (context, index){
                          AppointmentCancellationRedModel appointmentCancellationRedModel=_appointmentCancellationController.dataList[index];
                          return ListTile(
                            leading: Icon(Icons.circle,
                            size: 10,
                            color:appointmentCancellationRedModel.status=="Initiated"?Colors.yellow:
                            appointmentCancellationRedModel.status=="Rejected"?Colors.red:
                            appointmentCancellationRedModel.status=="Approved"?Colors.green:
                            appointmentCancellationRedModel.status=="Processing"?Colors.orange:
                            Colors.grey ,),
                            //'Initiated','Rejected','Approved','Processing'
                            title: Text(appointmentCancellationRedModel.status??"--",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500
                            ),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                appointmentCancellationRedModel.notes==null?Container():       Text(appointmentCancellationRedModel.notes??"--",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                    )
                                ),
                                Text(DateTimeHelper.getDataFormat(appointmentCancellationRedModel.createdAt??"--"),
                                  style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                    )
                                ),
                                Divider(
                                  color: Colors.grey.shade100,
                                )
                              ],
                            ),
                          );
                        }

                    ),
                 );

            }
          }else {
            return Container();
          } //Error svg

        }),

    );
  }

  _buildPrescriptionListBox() {
    return Card(
      color:  ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
      ListTile(
        title:  const Text("Prescription" ,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),),
        subtitle: Obx(()
        {
          if (!_prescriptionController.isError.value) { // if no any error
            if (_prescriptionController.isLoading.value) {
              return const  ILoadingIndicatorWidget();
            } else {
              return _prescriptionController.dataList.isEmpty?const Text("No Prescription Found!",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,

                ),):
              ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount:_prescriptionController.dataList.length ,
                  itemBuilder: (context, index){
                    PrescriptionModel prescriptionModel=_prescriptionController.dataList[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Text("Prescription #${prescriptionModel.id??"--"}",
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                            ),),
                          IconButton(onPressed: ()async{
                    if(prescriptionModel.pdfFile!=null&&prescriptionModel.pdfFile!=""){
                     await  launchUrl(Uri.parse("${ApiContents.imageUrl}/${prescriptionModel.pdfFile}"),
                         mode: LaunchMode.externalApplication);
                    }else{
                     await  launchUrl(Uri.parse("${ApiContents.prescriptionUrl}/${prescriptionModel.id}"),
                         mode: LaunchMode.externalApplication);
                    }
                          }, icon: const Icon(Icons.download,
                          color: Colors.green,
                            size: 25,
                          )),
                          prescriptionModel.pdfFile!=null&&prescriptionModel.pdfFile!=""?Container():    IconButton(onPressed: (){

                              Get.toNamed(RouteHelper.getAddPrescriptionPageRoute(appId: widget.appId??"",prescriptionId: prescriptionModel.id.toString()));

                          }, icon: const Icon(Icons.edit,
                            color: Colors.grey,
                            size: 25,
                          )),

                          IconButton(onPressed: (){
                            _openDialogDeletePrescriptionBox(prescriptionModel.id.toString());
                          }, icon: const Icon(Icons.delete,
                            color: Colors.redAccent,
                            size: 25,
                          ))


                        ],
                      ),
                      subtitle: Text(DateTimeHelper.getDataFormat(prescriptionModel.createdAt.toString()),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13
                      ),
                      ),
                    );
                  }

              );

            }
          }else {
            return Container();
          } //Error svg

        }),
      ),

    );
  }

  _buildPatientFileListBox() {
    return Card(
      color:  ColorResources.cardBgColor,
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
      ListTile(
        onTap:patientFileMode.isEmpty?null: (){
       //   Get.to(()=>PatientFilePage(patientId: appointmentModel?.patientId.toString()??"", patientName: "${appointmentModel?.pFName??""} ${appointmentModel?.pLName??""}"));
        Get.toNamed(RouteHelper.getPatientFilePagePageRoute(patientId: appointmentModel?.patientId.toString()??""));
        },
        title:  const Text("Patient Files" ,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),),
        subtitle: patientFileMode.isEmpty?const Text("No FIle Found!",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,

          ),):
        const Text("Click here to check the patient file",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,

          ),),
      ),

    );
  }
  _openBottomSheetAppointmentStatus(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        RichText(
                          text: TextSpan(
                            text: 'Current appointment status is ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: appointmentModel?.status ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        RadioListTile(
                            selectedTileColor: ColorResources.btnColor,
                            title: const Text("Visited",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                              ),),
                            subtitle: const Text("Can be marked if the appointment is either OPD or Emergency.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13
                              ),),
                            value: "Visited",
                            groupValue: selectedAppointmentStatus,
                            onChanged:appointmentModel?.type!="Video Consultant"? (value){
                              setState((){
                                selectedAppointmentStatus="Visited";
                              });
                            }:null),
                        RadioListTile(
                            title: const Text("Rescheduled",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                              ),),
                            value: "Rescheduled",
                            groupValue: selectedAppointmentStatus,
                            onChanged: (value){
                              setState((){
                                selectedAppointmentStatus="Rescheduled";
                              });
                            }),
                        RadioListTile(
                            subtitle: const Text("Can be marked if the appointment is Video Consultant.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13
                              ),),
                            title: const Text("Completed",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                              ),),
                            value: "Completed",
                            groupValue: selectedAppointmentStatus,
                            onChanged: appointmentModel?.type=="Video Consultant"?
                                (value){
                              setState((){
                                selectedAppointmentStatus="Completed";
                              });
                            }:null),
                        RadioListTile(
                            title: const Text("Rejected",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                              ),),
                            value: "Rejected",
                            groupValue: selectedAppointmentStatus,
                            onChanged: (value){
                              setState((){
                                selectedAppointmentStatus="Rejected";
                              });
                            }),
                        RadioListTile(
                            title: const Text("Pending",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                              ),),
                            value: "Pending",
                            groupValue: selectedAppointmentStatus,
                            onChanged: (value){
                              setState((){
                                selectedAppointmentStatus="Pending";
                              });
                            }),
                        RadioListTile(
                            title: const Text("Confirmed",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                              ),),
                            value: "Confirmed",
                            groupValue: selectedAppointmentStatus,
                            onChanged: (value){
                              setState((){
                                selectedAppointmentStatus="Confirmed";
                              });
                            }),

                        SmallButtonsWidget(title: "Save", onPressed:selectedAppointmentStatus==appointmentModel?.status?null:
                            (){
                          Get.back();
                          if(selectedAppointmentStatus=="Rescheduled"){_openBottomCalenderSheet();}
                          else{ _openDialogBox();}

                        }),
                      ],
                    ),
                  ),
                );
              }
          );
        },

      ).whenComplete(() {

      });
  }
  void _handleUpdateStatus() async{
    setState(() {
      _isLoading=true;
    });
    final res=await  AppointmentService.updateStatus(
        appointmentId: appointmentModel?.id.toString()??"",
        status: selectedAppointmentStatus);
    if (res != null) {
      IToastMsg.showMessage("success");
      getAndSetData();
    }
    setState(() {
      _isLoading=false;
    });
  }

  void _handleUpdateStatusToCancel() async{
    setState(() {
      _isLoading=true;
    });
    final res=await  AppointmentService.updateStatusToCancel(
        appointmentId: appointmentModel?.id.toString()??"",
        );
    if (res != null) {
      IToastMsg.showMessage("success");
      _appointmentCancellationController.getData(appointmentId: widget.appId??"-1");
      getAndSetData();
    }
    setState(() {
      _isLoading=false;
    });
  }
  void _handleUpdateStatusToResch() async{
    setState(() {
      _isLoading=true;
    });
    final res=await  AppointmentService.updateStatusToResch(
      appointmentId: appointmentModel?.id.toString()??"",
      date: _selectedDate,
      timeSlots: _setTime
    );
    if (res != null) {
      IToastMsg.showMessage("success");
      getAndSetData();
    }
    setState(() {
      _isLoading=false;
    });
  }
  void _handleUpdateStatusReject() async{
    setState(() {
      _isLoading=true;
    });
    final res=await  AppointmentService.updateStatusToReject(
        appointmentId: appointmentModel?.id.toString()??"",
    );
    if (res != null) {
      IToastMsg.showMessage("success");
      getAndSetData();
    }
    setState(() {
      _isLoading=false;
    });
  }
  _openDialogBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title:  Text(
            selectedAppointmentStatus,
            textAlign:  TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content:  Column(
            mainAxisSize: MainAxisSize.min,
            children:  [
              Text(
                  selectedAppointmentStatus=="Rejected"?"Once an appointment is marked as Rejected, its status cannot be changed. Additionally, if any payment has been made by the user, it can be refunded to their wallet.\nAre you sure want to update status from ${appointmentModel?.status??""} to $selectedAppointmentStatus"
                  :selectedAppointmentStatus=="Cancelled"?"Once an appointment is marked as Cancelled, its status cannot be changed. Additionally, if any payment has been made by the user, it can be refunded to their wallet.\nAre you sure want to update status from ${appointmentModel?.status??""} to $selectedAppointmentStatus"
                      :selectedAppointmentStatus=="Rescheduled"?"Are you sure want to rescheduled appointment from ${DateTimeHelper.getDataFormat(appointmentModel?.date??"")} -  ${appointmentModel?.timeSlot??""} to ${DateTimeHelper.getDataFormat(_selectedDate)} - $_setTime"
                      :"Are you sure want to update status from ${appointmentModel?.status??""} to $selectedAppointmentStatus",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              const  SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text("No",
                    style:
                    TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400, fontSize: 12)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text(
                  "Yes",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400, fontSize: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  switch(selectedAppointmentStatus){
                    case "Rejected":
                      _handleUpdateStatusReject();
                      break;
                    case "Cancelled":
                      _handleUpdateStatusToCancel();
                      break;

                    case "Rescheduled":
                      _handleUpdateStatusToResch();
                      break;

                    default:     _handleUpdateStatus();
                  }



                }),
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }
  _openDialogDeletePrescriptionBox(String id) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title:  const Text(
            "Delete",
            textAlign:  TextAlign.center,
            style:  TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content:  Column(
            mainAxisSize: MainAxisSize.min,
            children:  [
              Text("Are you sure want to delete prescription #$id",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              const  SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text("No",
                    style:
                    TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400, fontSize: 12)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Change this value to adjust the border radius
                  ),
                ),
                child: const Text(
                  "Yes",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400, fontSize: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleDeletePrescription(id);

                }),
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }
  void _handleDeletePrescription(String id) async{
    setState(() {
      _isLoading=true;
    });
    final res=await  PrescriptionService.deleteData(
      id: id
    );
    if (res != null) {
      IToastMsg.showMessage("success");
      _prescriptionController.getData(appointmentId: widget.appId??"");
    }
    setState(() {
      _isLoading=false;
    });
  }
  _openBottomCalenderSheet(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,
        isScrollControlled: true,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: const BoxDecoration(
                      color: ColorResources.bgColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                      ),
                    ),
                    //  height: 260.0,
                    child:Stack(
                      children: [
                        Positioned(
                            top: 10,
                            right: 20,
                            left: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Choose Date And Time",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                  ),),
                                IconButton(
                                    onPressed: (){
                                      Get.back();
                                    }, icon: const Icon(Icons.close)),
                              ],
                            )),

                        Positioned(
                            top: 60,
                            left: 5,
                            right: 5,
                            bottom: 0,
                            child: ListView(
                              children: [
                                _buildCalendar(),
                                const  Divider(),
                                Obx(() {
                                  if (!_timeSlotsController.isError.value&&!_bookedTimeSlotsController.isError.value) { // if no any error
                                    if (_timeSlotsController.isLoading.value||_bookedTimeSlotsController.isLoading.value) {
                                      return const ILoadingIndicatorWidget();
                                    } else if (_timeSlotsController.dataList.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text("Sorry, no available time slots were found for the selected date",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red
                                          ),),
                                      );
                                    }
                                    else {
                                      return
                                        _slotsGridView(setState, _timeSlotsController.dataList, _bookedTimeSlotsController.dataList);
                                    }
                                  }else {
                                    return  const Text("Something Went Wrong");
                                  } //Error svg
                                }
                                )

                              ],
                            )
                        ),
                      ],
                    )
                );
              }
          );
        },
      ).whenComplete(() {

      });
  }
  Widget _buildCalendar() {
    return SizedBox(
      height: 100,
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: DateTime.now(),
        selectionColor: ColorResources.primaryColor,
        selectedTextColor: Colors.white,
        daysCount: 7,
        onDateChange: (date) {
          // New date selected
          setState(() {
            final dateParse =  DateFormat('yyyy-MM-dd').parse((date.toString()));
          //  print(dateParse);
            _selectedDate = DateTimeHelper.getYYYMMDDFormatDate(date.toString());
            _timeSlotsController.getData(appointmentModel?.doctorId.toString()??"", DateTimeHelper.getDayName(dateParse.weekday),appointmentModel?.type=="Video Consultant"?"2":"1");
            _bookedTimeSlotsController.getData(appointmentModel?.doctorId.toString()??"", _selectedDate,appointmentModel?.type??"");
          });
        },
      ),
    );
  }
  Widget _slotsGridView(setStatem, List<TimeSlotsModel> timeSlots, List<BookedTimeSlotsModel> bookedTimeSlots) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: timeSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 2 / 1, crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return buildTimeSlots(timeSlots[index].timeStart??"--",timeSlots[index].timeEnd??"--",setState,bookedTimeSlots);
      },
    );
  }
  Widget buildTimeSlots(String timeStart, String timeEnd,setState,bookedTimeSlots) {
    return GestureDetector(
      onTap: getCheckBookedTimeSlot(timeStart,bookedTimeSlots)?null:() {
        if(_selectedDate==appointmentModel?.date){
           String appointmentTime=appointmentModel?.timeSlot??"" ;
           final  splitSelectedTime=timeStart;
            final splitAppointmentTime=appointmentTime.split(":");
            if(splitAppointmentTime[0]==splitSelectedTime[0]){
              if(splitAppointmentTime[1]==splitSelectedTime[1]){
                  IToastMsg.showMessage("Select the different time");
                  return;
              }
            }
        }
        _setTime = timeStart;
        setState(() {});
        this.setState(() {

        });
       Get.back();
        _openDialogBox();

      },
      child: Card(
        color:  getCheckBookedTimeSlot(timeStart,bookedTimeSlots)?Colors.red:_setTime == timeStart
            ? ColorResources.primaryColor
            : Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              "$timeStart - $timeEnd",
              style: TextStyle(
                  color: timeStart == _setTime ? Colors.white : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
  bool  getCheckBookedTimeSlot(String timeStart,List<BookedTimeSlotsModel> bookedTimeSlots) {
    bool retuenValue=false;
    for(var element in bookedTimeSlots){
      if(element.timeSlots==timeStart){
        retuenValue=true;
        break;
      }
    }
    return retuenValue;

  }
  _openBottomSheet(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const   Text('Choose Prescription Mode ',
                              style:  TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              )),
                          const SizedBox(height: 20),
                          Card(
                            color:  ColorResources.cardBgColor,
                            elevation: .1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.edit,
                                color: ColorResources.btnColor,
                              size: 20,),
                              title: Text("Hand Written Mode",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,

                              ),
                              ),
                              onTap: (){
                                Get.back();
                                PrescriptionPreFieldModel prescriptionPreFieldModel=PrescriptionPreFieldModel(
                                  patientId: appointmentModel?.patientId.toString()??"",
                                  doctorDept: appointmentModel?.departmentTitle??"",
                                  doctorName:"${appointmentModel?.doctFName??""} ${appointmentModel?.doctLName??""}",
                                  doctorSpec: appointmentModel?.doctSpecialization??"",
                                  patientAge: appointmentModel!.pDob==null?"":DateTimeHelper.calculateAge(appointmentModel!.pDob!).toString(),
                                  patientGender:appointmentModel?.pGender??"",
                                  patientName: "${appointmentModel?.pFName??""} ${appointmentModel?.pLName??""}",
                                  patientPhone:appointmentModel?.pPhone??"",
                                  appointmentID:appointmentModel?.id.toString()??"",
                                  clinicId: appointmentModel?.clinicId.toString()

                                );
                                // Get.toNamed(RouteHelper.getWritePrescriptionPage());
                                Get.to(()=>WritePrescriptionPage(
                                  prescriptionPreFieldModel: prescriptionPreFieldModel,
                                  prescriptionModel: null,
                                ));

                                //   Get.toNamed(RouteHelper.getAddPrescriptionPageRoute(appId: widget.appId??"",prescriptionId: ""));
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color:  ColorResources.cardBgColor,
                            elevation: .1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.pending_actions,
                                color: ColorResources.btnColor,
                                size: 20,),
                              title: Text("Predefined Mode",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,

                                ),
                              ),
                              onTap: (){
                                Get.back();
                                Get.toNamed(RouteHelper.getAddPrescriptionPageRoute(appId: widget.appId??"",prescriptionId: ""));
                              },
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        },

      ).whenComplete(() {

      });
  }

}
