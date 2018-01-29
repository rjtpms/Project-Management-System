//
//  FIRService.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class FIRService: NSObject {
    enum FIRServiceError: Error {
        case pathNotFoundInDatabase
        case noUserLoggedIn
        case taskDoesNotExist
		case failParseProjectInfo
        case userDoesNotExist
        case failedToGetUserInfo
		case failParseUserInfo
    }
	
	typealias LoginResultHandler = (User?, Error?) -> ()
	typealias FetchProjectResultHandler = (Project?, Error?) -> ()
	typealias FetchProjectsResultHandler = ([Project]?, Error?) -> ()
	typealias FetchUserResulHandler = (Member?, Error?) -> ()
	typealias SearchMembersResultHandler = ([Member]?, Error?) -> ()
	
	static let shareInstance = FIRService()
	
	// Database refences
	private var userRef: DatabaseReference!
	private var databaseRef : DatabaseReference!
	private var storageRef: StorageReference!
	
	private override init() {
		userRef = Database.database().reference().child("Users")
		databaseRef = Database.database().reference()
		storageRef = Storage.storage().reference()
	}
    
	
	// create user profile in DB
    func createUserProfile(ofUser uid: String, name: String?, email: String?, role: String?) {
        let userDict = ["name": name!, "email": email!, "role": role!] as [String: Any]
		databaseRef.child("Users").child(uid).updateChildValues(userDict)
	}
    
    func createOrDeleteTask(task: Task, toCreate: Bool, completion: @escaping (Error?) -> ()) {
        guard let userId = CurrentUser.sharedInstance.userId else {
            completion(FIRServiceError.noUserLoggedIn)
            return
        }
        
        // create task and add to "Tasks" table
        let key = databaseRef.child("Tasks").childByAutoId().key
        let taskDict = ["title": task.title!, "description": task.description!, "start date": task.startDate!.timeIntervalSince1970, "due date": task.dueDate!.timeIntervalSince1970, "projectID": task.projectId!, "isCompleted": false] as [String : Any]
		
        databaseRef.child("Tasks").child(key).updateChildValues(taskDict)
		
		// add task id to project table
		let projectTaskDict = [task.id: true]
        databaseRef.child("Projects").child(task.projectId!).child("tasks").updateChildValues(projectTaskDict)
        
        // add the manager who created the task to the task's member list
        assignTaskToUser(taskId: key, userId: userId) { (err) in
            if err != nil {
                print(err!)
            }
            completion(err)
        }
        
    }
    
    func updateTask(task: Task) {
        // update task in "Tasks" table
        let taskDict = ["title": task.title!, "description": task.description!, "start date": task.startDate!.timeIntervalSince1970, "due date": task.dueDate!.timeIntervalSince1970, "projectID": task.projectId!, "isCompleted": task.isCompleted!] as [String : Any]
        databaseRef.child("Tasks").child(task.id).updateChildValues(taskDict)
    }
    
    func setCompletionStatus(ofTask taskId: String, to status: Bool) {
        databaseRef.child("Tasks").child(taskId).child("isCompleted").setValue(status)
    }
    
    func assignTaskToUser(taskId: String, userId: String, completion: @escaping (Error?) -> ()) {
       // add task to user's tasks list
        databaseRef.child("Users").child(userId).child("tasks").child(taskId).setValue(true)
        
       // add user to task's members list
        databaseRef.child("Tasks").child(taskId).child("members").child(userId).setValue(true)
        completion(nil)
    }
    
    func getTaskInfo(ofTask id: String, completion: @escaping (Task?, Error?) -> ()) {
        let ref = databaseRef.child("Tasks").child(id)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var taskDict : [String: Any]
            taskDict = snapshot.value as? [String: Any] ?? [:]
            let task = Task(id: id)
            task.title = taskDict["title"] as? String
            task.description = taskDict["description"] as? String
            if let startTimestamp = taskDict["start date"] as? TimeInterval{
                task.startDate = Date(timeIntervalSince1970: startTimestamp)
            }
            if let dueTimestamp = taskDict["due date"] as? TimeInterval {
                task.dueDate = Date(timeIntervalSince1970: dueTimestamp)
            }
            
            task.members = []
            if let members = taskDict["members"] as? [String: Any] {
                let memberIds = Array(members.keys)
                for memberId in memberIds {
                    task.members?.append(memberId)
                }
            }
            
            task.isCompleted = taskDict["isCompleted"] as? Bool
            task.projectId = taskDict["projectID"] as? String
            
            completion(task, nil)
        })
    }
    
    
    func getUserInfo(ofUser id: String, completion: @escaping (Member?, Error?) -> ()) {
        userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String: Any],
                let email = userDict["email"] as? String,
                let name = userDict["name"] as? String,
                let photoUrl = userDict["profile photo"] as? String{
                
                let url = URL(string: photoUrl)
                var image : UIImage? = nil
                if let url = url {
                    image = self.downloadImageWithURL(url: url)
                }
                
                let member = Member(id: id);
                member.email = email
                member.name = name
                member.profileImage = image
                
                completion(member, nil)
            } else {
                completion(nil, FIRServiceError.failedToGetUserInfo)
            }
        }
    }
    
    func downloadImageWithURL(url: URL) -> UIImage! {
        do {
            let data = try NSData(contentsOf: url, options: NSData.ReadingOptions())
            return UIImage(data: data as Data)
        } catch {
            print(error)
        }
        return UIImage()
    }
    
    func uploadImage(ofId userId: String, with img: UIImage, completion: @escaping (StorageMetadata?, Error?) -> ()) {
        let data = UIImageJPEGRepresentation(img, 0.8)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = "ProfileImage/\(userId).jpeg"
        let childRef = storageRef?.child(imageName)
        guard let dt = data else {return}
        childRef?.putData(dt, metadata: metadata, completion: { (meta, error) in
            completion(meta, error)
            if let url = meta?.downloadURL()?.absoluteURL {
                self.databaseRef.child("Users").child(userId).child("profile photo").setValue("\(url)")
            }
        })
        
    }
    
    
    func getProfileImageUrl(ofUser id: String, completion: @escaping (URL?, Error?) -> ()) {
        let imageName = "ProfileImage/\(id).jpeg"
        let childRef = storageRef?.child(imageName)
        childRef?.getMetadata(completion: { (metadata, error) in
            if error != nil {
                completion(nil, error)
            } else {
                let url = metadata?.downloadURL()?.absoluteURL
                completion(url, nil)
            }
        })
    }
    
    
    func getAllTaskIds(ofUser uid: String, completion: @escaping ([String]?, Error?) -> ()) {
        let ref = databaseRef.child("Users").child(uid).child("tasks")
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var taskDict : [String: Any]
            taskDict = snapshot.value as? [String: Any] ?? [:]
            let tasks : [String] = Array(taskDict.keys)
            completion(tasks, nil)
        })
    }
	
	// Email,Password login
	func loginUser(with email: String, and password: String, completion: @escaping LoginResultHandler) {
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			DispatchQueue.main.async {
				completion(user, error)
			}
		}
	}
	
	// OAuth Login
	func loginUser(with credential: AuthCredential, completion: @escaping LoginResultHandler) {
		Auth.auth().signIn(with: credential) { (user, error) in
			DispatchQueue.main.async {
				completion(user, error)
			}
		}
	}
	
	// Save loggedin user info in Firebase Users table and store into as CurrentUser singleton
	func saveLoggedInUser(_ user: User, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		
		userRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
			if !snapshot.hasChild(user.uid) {
				// If record not exist, create one (only for OAuth)
				self?.userRef.child(user.uid).updateChildValues(
					["name": user.displayName ?? "",
					 "email": user.email!,
					 "profile photo": user.photoURL?.absoluteString ?? ""
					]
				)
				// save oAuth user info to current user
				currentUser.update(id: user.uid,
								   email: user.email!,
								   name: user.displayName!,
								   photoUrl: user.photoURL,
								   role: .none)
				currentUser.save()
				
				DispatchQueue.main.async {
					completion()
				}
			} else {
				// if record exist, fetch it
				self?.fetchUserInfo(with: user.uid) {_,_ in
					DispatchQueue.main.async {
						completion()
					}
				}
			}
		}
	}
	
	// Fetch currentuser info from firebase and store in singleton
	func fetchUserInfo(with id: String, completion: @escaping FetchUserResulHandler) {
		userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
			if let userDict = snapshot.value as? [String: Any],
				let email = userDict["email"] as? String,
				let name = userDict["name"] as? String {
				
				// handle situation when user login Oauth but close app in choose role page
				var role: Role!
				if userDict["role"] == nil {
					role = Role.none
				} else {
					role = Role(rawValue: userDict["role"] as! String)
				}
				
				var photoUrl: URL?
				if let profileUrlStr = userDict["profile photo"] as? String {
					photoUrl = URL(string: profileUrlStr)
				}
				
				// init currentUser if not exsit, otherwise update it
				let currentUser = CurrentUser.sharedInstance
				if currentUser.userId == nil || currentUser.userId == id {
					currentUser.update(id: id,
									   email: email,
									   name: name,
									   photoUrl: photoUrl,
									   role: role)
					currentUser.save()
				}
				
				let resultMember = Member(id: id,
										  name: name,
										  email: email,
										  imageURL: photoUrl)
				DispatchQueue.main.async {
					completion(resultMember, nil)
				}
			} else {
				completion(nil, FIRServiceError.failParseUserInfo)
			}
		}
	}
	
	// fetch all projects for manager
	func getAllProjects(with managerId: String, completion: @escaping FetchProjectsResultHandler) {
		let fetchProjectIdsGroup = DispatchGroup()
		let fetchProjectGroup = DispatchGroup()
		var error: Error?
		var projectIds: [String] = []
		var projectResults: [Project] = []
		
		fetchProjectIdsGroup.enter()
		getProjectIds(with: managerId) { (pIds, err) in
			fetchProjectIdsGroup.leave()
			guard error == nil, let unwrappedIds = pIds else {
				error = err
				completion(nil, error)
				return
			}
			projectIds = unwrappedIds
		}
		
		fetchProjectIdsGroup.notify(queue: .main) { [weak self] in
			for projectId in projectIds {
				fetchProjectGroup.enter()
				self?.getProjectInfo(with: projectId) { (project, err) in
					fetchProjectGroup.leave()
					guard error == nil, let unwrappedProject = project else {
						error = err
						completion(nil, error)
						return
					}
					projectResults.append(unwrappedProject)
				}
			}
			
			fetchProjectGroup.notify(queue: .main) {
				completion(projectResults.isEmpty ? nil : projectResults, error)
			}
		}
	}
	
	// find projects Ids associated with a user
	private func getProjectIds(with userId: String, completion: @escaping ([String]?, Error?) -> ()) {
		let ref = databaseRef
			.child("Users")
			.child(userId)
			.child("projects")
		
		ref.observeSingleEvent(of: .value){ (snapshot) in
			if let pIdDict = snapshot.value as? [String: Any] {
				let projectIds = Array(pIdDict.keys)
				completion(projectIds, nil)
			} else {
				completion(nil, FIRServiceError.pathNotFoundInDatabase)
			}
		}
	}
	
	// fetch projects for a member
	func getMemberProjects(with userId: String, completion: @escaping FetchProjectsResultHandler) {
		// key: project id, value: array of tasks Id current user is working on
		let getAllTaskIdsGroup = DispatchGroup()
		let getProjectIdsGroup = DispatchGroup()
		let getProjectsGroup = DispatchGroup()
		var projectResults: [Project] = []
		var taskIds: [String] = []
		var projectIds: [String] = []
		var error: Error?
		
		// fetch all tasks ids for this user
		getAllTaskIdsGroup.enter()
		getAllTaskIds(ofUser: userId) { (ids, err) in
			getAllTaskIdsGroup.leave()
			guard error == nil, let unwrappedIds = ids else {
				error = err
				return
			}
			taskIds = unwrappedIds
		}
		
		getAllTaskIdsGroup.notify(queue: .main) { [weak self] in
			// for each task we find it's associated project
			getProjectIdsGroup.enter()
			self?.getProjectIds(with: userId) { (pIds, err) in
				getProjectIdsGroup.leave()
				guard error == nil, let unwrappedIds = pIds else {
					error = err
					return
				}
				projectIds = unwrappedIds
			}
			
			getProjectIdsGroup.notify(queue: .main) { [weak self] in
				for projectId in projectIds {
					getProjectsGroup.enter()
					self?.getProjectInfo(with: projectId, filteredAgainst: taskIds) { (project, err) in
						getProjectsGroup.leave()
						guard error == nil, let unwrappedProject = project else {
							error = err
							return
						}
						projectResults.append(unwrappedProject)
					}
				}
				
				getProjectsGroup.notify(queue: .main) {
					// complete!
					completion(projectResults.isEmpty ? nil : projectResults, error)
				}
			}
		}
	}
	
	/**
		Note: when filteredAgainst is nil, fetch single project data with all the fields
		when filtedAgainst is provided, fetch a single project with only tasks ids that is in filtedAgainst
	*/
	func getProjectInfo(with projectId: String, filteredAgainst taskIds: [String]? = nil, completion: @escaping FetchProjectResultHandler) {
		let projectRef = databaseRef.child("Projects")
		
		projectRef.child(projectId).observeSingleEvent(of: .value) { (snapshot) in
			if let projectDict = snapshot.value as? [String: Any],
				let description = projectDict["description"] as? String,
				let dueDate = projectDict["due date"] as? TimeInterval,
				let startDate = projectDict["start date"] as? TimeInterval,
				let name = projectDict["name"] as? String,
				let managerId = projectDict["manager"] as? String {
				
				var project = Project(id: projectId,
									  description: description,
									  startDate: Date(timeIntervalSince1970: startDate),
									  endDate: Date(timeIntervalSince1970: dueDate),
									  name: name,
									  tasks: [],
									  members: [],
									  managerId: managerId)
				
				if let memberDict = projectDict["members"] as? [String: Any] {
					let memberIds = Array(memberDict.keys)
					for id in memberIds {
						project.members.append(Member(id: id))
					}
				}
				
				if let taskDict = projectDict["tasks"] as? [String: Any] {
					
					// filter only the taskIds that is in memeber's tasks list if taskIds is not nil
					let projectTaskIds = taskIds == nil ?
						Array(taskDict.keys) :
						Array(taskDict.keys).filter { taskIds!.contains($0) }
					
					for id in projectTaskIds {
						project.tasks.append(Task(id: id))
					}
				}
				
				completion(project, nil)
			} else {
				completion(nil, FIRServiceError.failParseProjectInfo)
			}
		}
	}
	
	// Create Project
	func updateProject(for project: Project, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		let projectRef = databaseRef.child("Projects").child(project.id)
		
		// create new project
		let projectDict = ["name": project.name,
						   "description": project.description,
						   "manager": currentUser.userId,
						   "start date": project.startDate.timeIntervalSince1970,
						   "due date": project.endDate.timeIntervalSince1970] as [String: Any]
		
		
		projectRef.updateChildValues(projectDict)
		
		// update manager's project list
		userRef.child(currentUser.userId).child("projects").updateChildValues([project.id: true])
		
		completion()
	}
    
    func updateUserName(ofUser uid: String, name: String) {
        // set database reference
        let ref = databaseRef.child("Users").child(uid).child("name")
        ref.setValue(name)
    }
	
	// search by name or email
	func searchMembers(using searchText: String, completion: @escaping SearchMembersResultHandler) {
		var resultIds: [String] = []
		var resultMembers: [Member] = []
		let searchGroup = DispatchGroup()
		let fetchMembersGroup = DispatchGroup()
			
		// get memberIds that has name starting with searchText
		
		let nameQuery = userRef
			.queryOrdered(byChild: "name")
			.queryStarting(atValue: searchText)
			.queryEnding(atValue: searchText + "\u{f8ff}")
		
		searchGroup.enter()
		nameQuery.observeSingleEvent(of: .value) { (snapshot) in
			searchGroup.leave()
			if let membersDict = snapshot.value as? [String: Any] {
				for (memberId, memberDict) in membersDict {
					// add memebrId to result when role is not manager, and id is not already in resultIds
					if !resultIds.contains(memberId),
					let role = (memberDict as? [String: Any])?["role"] as? String,
						role != "Project Manager"{
						resultIds.append(memberId)
					}
				}
			}
		}
		
		// get memberdIds that has email starting with searchText
		let emailSerchText = searchText.lowercased()
		let emailQuery = userRef
			.queryOrdered(byChild: "email")
			.queryStarting(atValue: emailSerchText)
			.queryEnding(atValue: emailSerchText + "\u{f8ff}")
		
		searchGroup.enter()
		emailQuery.observeSingleEvent(of: .value) { (snapshot) in
			searchGroup.leave()
			if let membersDict = snapshot.value as? [String: Any] {
				for (memberId, memberDict) in membersDict {
					// add memebrId to result when role is not manager, and id is not already in resultIds
					if !resultIds.contains(memberId),
						let role = (memberDict as? [String: Any])?["role"] as? String,
						role != "Project Manager"{
						resultIds.append(memberId)
					}
				}
			}
		}
		
		searchGroup.notify(queue: .main) { [weak self] in
			// now start fetching result members info
			for id in resultIds {
				fetchMembersGroup.enter()
				self?.fetchUserInfo(with: id) { (member, error) in
					fetchMembersGroup.leave()
					guard error == nil else { return }
					guard let unwrappedMember = member else { return }
					resultMembers.append(unwrappedMember)
				}
			}
			
			fetchMembersGroup.notify(queue: .main) {
				if resultMembers.isEmpty {
					completion(nil, FIRServiceError.userDoesNotExist)
				} else {
					completion(resultMembers, nil)
				}
			}
		}
	}
	
	func add(member memberId: String, toProject projectId: String) {
		let projectValue = [projectId: ""]
		let memberValue = [memberId: ""]
		let projectRef = databaseRef.child("Projects").child(projectId)
		userRef.child(memberId).child("projects").updateChildValues(projectValue)
		projectRef.child("members").updateChildValues(memberValue)
	}
	
	func remove(member memberId: String, fromProject projectId: String) {
		// remove projectId from user
		userRef
			.child(memberId)
			.child("projects")
			.child(projectId)
			.removeValue()
		
		// remove userId from project
		databaseRef
			.child("Projects")
			.child(projectId)
			.child("members")
			.child(memberId)
			.removeValue()
		
		// remove member from task which belongs to the project
		userRef
			.child(memberId)
			.child("tasks")
			.observeSingleEvent(of: .value) { [weak self] (snapshot) in
				guard let taskDict = snapshot.value as? [String: Any] else { return }
				
				let taskIds = Array(taskDict.keys)
				for taskId in taskIds {
					let taskRef = self?.databaseRef.child("Tasks").child(taskId)
					
					taskRef?.observeSingleEvent(of: .value) { (snapshot) in
						// if this user task is associate with the project user is removed from, then remove user from task
						guard let pId = (snapshot.value as? [String: Any])?["projectID"] as? String,
							pId == projectId else { return }
						
						taskRef?.child("members").child(memberId).removeValue()
					}
				}
		}
	}
	
	func deleteProject(of id: String, managedBy managerId: String) {
		// remove project from manager
		
	}
}
