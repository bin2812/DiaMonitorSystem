import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../model/social_mdia_model.dart';
import '../service/configuration_service.dart';
import '../service/social_media_servcie.dart';
import '../utilities/api_content.dart';
import '../utilities/image_constants.dart';
import '../widget/app_bar_widget.dart';
import '../widget/image_box_widget.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  ScrollController scrollController=ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAppBar.commonAppBar(title: "Contact Us"),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      controller: scrollController,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height/2,
          child:
          //Container(color: Colors.red,)
          SvgPicture.asset(
              ImageConstants.appShareImage,
              semanticsLabel: 'Acme Logo'
          ),
        ),
        const SizedBox(height: 10),
    const Text("Contact Us",
    textAlign: TextAlign.center,
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold
    ),
    ),
        const SizedBox(height: 20),
        FutureBuilder(
          future: ConfigurationService.getDataById(idName: "c_u_p_d_d_a"),
          builder: (context, snapshot) {
            return snapshot.hasData? Text("${snapshot.data?.value}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                letterSpacing: 1,
                fontSize: 15,

              ),
            ):const Text("--");
          }
        ),
       const  Divider(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const   Icon(Icons.home),
              const SizedBox(width: 10),
              Flexible(child:
              FutureBuilder(
                  future: ConfigurationService.getDataById(idName: "address"),
                  builder: (context, snapshot) {
                    return snapshot.hasData?  Text("Address: ${snapshot.data?.value??"--"}",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        letterSpacing: 1,
                        fontSize: 15,

                      ),
                    ):const Text("--");
                  }
              ),
             )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const Icon(Icons.phone),
              const  SizedBox(width: 10),
              Flexible(child:
              FutureBuilder(
                  future: ConfigurationService.getDataById(idName: "phone"),
                  builder: (context, snapshot) {
                    return snapshot.hasData? Text("Phone: ${snapshot.data?.value??"--"}",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        letterSpacing: 1,
                        fontSize: 15,

                      ),
                    ):const Text("--");
                  }
              ),

             )
            ],
          ),
        ),
        const  Divider(),
        FutureBuilder(
            future: SocialMediaService.getData(),
            builder: (context,snapshot){
              return snapshot.hasData?
                  ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length??0,
                      itemBuilder: (context,index){

                    SocialMediaModel socialMedialModel=snapshot.data![index];
                    return Card(
                      elevation: .1,
                    child: ListTile(
                      onTap: ()async {
                        if(socialMedialModel.url!=null){
                          try{
                            await launchUrl(Uri.parse(socialMedialModel.url!),
                            mode: LaunchMode.externalApplication);
                          }
                          catch(e){if (kDebugMode) {
                            print(e);
                          }}
                        }
                      },
                      contentPadding: const EdgeInsets.all(8),
                      leading: socialMedialModel.image==null?const Icon(Icons.image):SizedBox(
                          width: 50,
                          height: 50,
                          child: ImageBoxFillWidget(imageUrl: "${ApiContents.imageUrl}/${socialMedialModel.image}")),
                      title:Text(socialMedialModel.title??"",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14
                          )) ,
                    ),
                  );})
                  :Container();

               })

      ],
    );
  }
}
