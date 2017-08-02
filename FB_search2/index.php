<?php
require_once __DIR__ . '/php-graph-sdk-5.0.0/src/Facebook/autoload.php';
session_start();
$fb = new Facebook\Facebook([
  'app_id' => '227713354364290',
  'app_secret' => '79dea18f08661ba5087975a850c15b7f',
  'default_graph_version' => 'v2.8',
  'default_access_token' => 'EAADPGqWY9YIBAJdZBNINZChjIReM5RZAGTdXB8jOlaqJ9b2Gm80s2ceXfc0TjhcjaB27U3Y1vg5S7wbh2ZCVIqVp55v3Y6ympWo2Hw83gacQ2Q0VZASy6vQqv3UzbYZApdZAZAatAxKAxNKTgGZAqsn5zyD9GWXH1GrkZD',
  ]);

   
    if(isset($_GET)){
        if(isset($_GET['button'])){
            $upcoming_user;
            $hasPagination = array();
            $user = $_SESSION['user'];
            if($_GET['button'] == 'next'){
                $upcoming_user = $fb->next($user);
            } else if($_GET['button'] == 'previous'){
                $upcoming_user = $fb->previous($user);
            }
            $_SESSION['user'] = $upcoming_user;
            
        
            $data = array();
         
            foreach ($upcoming_user as $value){
                $id = $value['id'];
                $name = $value['name'];
                $picture_url = $value['picture']['url'];
             
            //$list = array();
                $list = (object)array('id' => $id, 'name' => $name, 'url' => $picture_url); 
                array_push($data,$list);
            }
            $hasNext;
            $hasPrev;
            if($fb->next($upcoming_user)== null){
                $hasNext = false;
            } else {
                $hasNext = true;
            }
            if($fb->previous($upcoming_user)== null){   
                $hasPrev = false;
            }else {
                $hasPrev = true;
            }
           $hasPagination['hasNext'] = $hasNext;
            $hasPagination['hasPrev'] = $hasPrev;
            array_push($data,$hasPagination);
         
            
            echo json_encode($data);
            
            
        } elseif(!isset($_GET['id'])){
             $hasPagination = array();
            $kw = $_GET['keyword'];
            $type = $_GET['tab'];
        
            if($type == 'place'){
        
            
            $lat = $_GET['latitude'];
            $long = $_GET['longitude'];
            
            
            $page_to_query = "search?q=".$kw."&type=place&center=".$lat.",".$long."&fields=id,name,picture.width(700).height(700)";
        } else {
        
            $page_to_query = "search?q=".$kw.'&type='.$type.'&fields=id,name,picture.width(700).height(700)';
        }
        
        
        try{
            $res = $fb->get($page_to_query);
        }
        catch(Facebook\Exceptions\FacebookResponseException $e) {
            echo 'Graph returned an error: ' . $e->getMessage();
            exit;
        }  
        catch(Facebook\Exceptions\FacebookSDKException $e) {
            echo 'Facebook SDK returned an error: ' . $e->getMessage();
            exit;
        }
        $user = $res->getGraphEdge();
//        $sam = $fb->next($ruser);
//        $sam_prev = $fb->previous($sam);
//        echo $sam_prev;

        $_SESSION['user'] = $user;
            
        
        $data = array();
         
        foreach ($user as $value){
            $id = $value['id'];
            $name = $value['name'];
            $picture_url = $value['picture']['url'];
             
            //$list = array();
            $list = (object)array('id' => $id, 'name' => $name, 'url' => $picture_url); 
            array_push($data,$list);
        }
            
        $hasNext;
        $hasPrev;
        if($fb->next($user)== null){
            $hasNext = false;
        }else {
                $hasNext = true;
        }
         if($fb->previous($user)== null){   
            $hasPrev = false;
        }else {
                $hasPrev = true;
            }
        $hasPagination['hasNext'] = $hasNext;
        $hasPagination['hasPrev'] = $hasPrev;
            
          
        array_push($data,$hasPagination);
        echo json_encode($data);
         
        // echo "normal call";  
      //  echo json_encode($hasPagination);
               
        } else {
            
            $my_id = $_GET['id'];
            $details_url = $my_id."?fields=id,name,picture.width(700).height(700),albums.limit(5){name,photos.limit(2){nam
e, picture}},posts.limit(5)";
      
        try{
            $res = $fb->get($details_url);
        }
        catch(Facebook\Exceptions\FacebookResponseException $e) {
            echo 'Graph returned an error: ' . $e->getMessage();
            exit;
        }  
        catch(Facebook\Exceptions\FacebookSDKException $e) {
            echo 'Facebook SDK returned an error: ' . $e->getMessage();
            exit;
        }
        $details_object = $res->getGraphObject();
            
            
            
            foreach ($details_object['albums'] as $det){
                 
                 foreach ($det['photos'] as $img_obj){
                    
                $img_url = $img_obj['id']."?fields=images";
                    
                try{
                    $img_res = $fb->get($img_url);
                }
                catch(Facebook\Exceptions\FacebookResponseException $e) {
                    echo 'Graph returned an error: ' . $e->getMessage();
                    exit;
                }  
                catch(Facebook\Exceptions\FacebookSDKException $e) {
                    echo 'Facebook SDK returned an error: ' . $e->getMessage();
                    exit;
                }
                
                $img_user = $img_res->getGraphObject();
                $hd_img_url = $img_user['images'][0]['source'];
                $img_obj['picture'] = $hd_img_url;
                }
            }
              
            
        echo $details_object;
          
        }
    }
?>

