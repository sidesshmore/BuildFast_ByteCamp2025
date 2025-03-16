
import { useState, useRef } from 'react';
import { Button } from "@/components/ui/button";
import { Upload, File, X, FileText, Image as ImageIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface FileUploadProps {
  onFileSelect: (file: File) => void;
  accept?: string;
  label: string;
  fileUrl?: string | null;
  fileType?: 'image' | 'document';
  className?: string;
}

const FileUpload = ({ 
  onFileSelect, 
  accept = 'image/*', 
  label, 
  fileUrl, 
  fileType = 'image', 
  className 
}: FileUploadProps) => {
  const [dragging, setDragging] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setDragging(true);
  };

  const handleDragLeave = () => {
    setDragging(false);
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setDragging(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const file = e.dataTransfer.files[0];
      handleFileChange(file);
    }
  };

  const handleFileChange = (file: File) => {
    setSelectedFile(file);
    onFileSelect(file);
  };

  const openFileSelector = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      handleFileChange(e.target.files[0]);
    }
  };

  const handleClearFile = () => {
    setSelectedFile(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  // Display the filename if selected
  const displayFileName = selectedFile ? selectedFile.name : fileUrl ? new URL(fileUrl).pathname.split('/').pop() : '';
  
  const isImage = fileType === 'image';
  const IconComponent = isImage ? ImageIcon : FileText;

  return (
    <div className={cn("space-y-2", className)}>
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleInputChange}
        accept={accept}
        className="hidden"
      />
      
      {fileUrl && !selectedFile && isImage ? (
        <div className="relative rounded-md overflow-hidden border border-border">
          <img 
            src={fileUrl} 
            alt="Uploaded file" 
            className="w-full h-40 object-cover"
          />
          <div className="absolute top-2 right-2">
            <Button
              type="button"
              variant="destructive"
              size="icon"
              className="h-6 w-6 rounded-full"
              onClick={openFileSelector}
            >
              <Upload className="h-3 w-3" />
            </Button>
          </div>
        </div>
      ) : fileUrl && !selectedFile ? (
        <div className="flex items-center gap-2 p-2 rounded-md border border-border">
          <FileText className="h-5 w-5 text-primary" />
          <span className="text-sm truncate flex-1">{displayFileName}</span>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={openFileSelector}
            className="h-7"
          >
            <Upload className="h-3 w-3 mr-1" />
            Change
          </Button>
        </div>
      ) : (
        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          className={cn(
            "border-2 border-dashed rounded-md p-6 text-center cursor-pointer transition-all",
            dragging ? "border-primary bg-primary/5" : "border-border hover:border-primary/50",
            className
          )}
          onClick={openFileSelector}
        >
          <div className="flex flex-col items-center justify-center gap-2">
            <div className="rounded-full bg-primary/10 p-3">
              <IconComponent className="h-6 w-6 text-primary" />
            </div>
            <div className="space-y-1">
              <p className="text-sm font-medium">{label}</p>
              <p className="text-xs text-muted-foreground">
                Drag and drop or click to upload
              </p>
            </div>
          </div>
        </div>
      )}
      
      {selectedFile && (
        <div className="flex items-center gap-2 p-2 rounded-md border border-border bg-secondary/30">
          <File className="h-4 w-4 text-primary" />
          <span className="text-sm truncate flex-1">{selectedFile.name}</span>
          <Button
            type="button"
            variant="ghost"
            size="icon"
            onClick={handleClearFile}
            className="h-6 w-6 hover:bg-destructive/10 hover:text-destructive"
          >
            <X className="h-3 w-3" />
          </Button>
        </div>
      )}
    </div>
  );
};

export default FileUpload;
